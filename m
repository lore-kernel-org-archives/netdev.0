From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 2/3 v3] net: ipv4 sysctl option to ignore routes
 when nexthop link is down
Date: Wed, 10 Jun 2015 20:00:14 -0700
Message-ID: <CAE4R7bCXehOuybGyDMHmzEHw_4X7d3G345EXYCyMCrC7c4oe8g@mail.gmail.com>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com>
 <1433990233-958-3-git-send-email-gospo@cumulusnetworks.com> <5578F92B.8060604@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:32944 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbbFKDAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 23:00:36 -0400
Received: by qkhg32 with SMTP id g32so34669385qkh.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 20:00:35 -0700 (PDT)
In-Reply-To: <5578F92B.8060604@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 7:57 PM, YOSHIFUJI Hideaki
<hideaki.yoshifuji@miraclelinux.com> wrote:
> Hi,
>
> Andy Gospodarek wrote:
>> This feature is only enabled with the new per-interface or ipv4 global
>> sysctls called 'ignore_routes_with_linkdown'.
>>
>> net.ipv4.conf.all.ignore_routes_with_linkdown = 0
>> net.ipv4.conf.default.ignore_routes_with_linkdown = 0
>> net.ipv4.conf.lo.ignore_routes_with_linkdown = 0
> :
>> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>> Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
>> ---
> :
>> diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
>> index 7e7746a..c9d0a0e 100644
>> --- a/kernel/sysctl_binary.c
>> +++ b/kernel/sysctl_binary.c
>> @@ -253,6 +253,7 @@ static const struct bin_table bin_net_ipv4_conf_vars_table[] = {
>>       { CTL_INT,      NET_IPV4_CONF_NOPOLICY,                 "disable_policy" },
>>       { CTL_INT,      NET_IPV4_CONF_FORCE_IGMP_VERSION,       "force_igmp_version" },
>>       { CTL_INT,      NET_IPV4_CONF_PROMOTE_SECONDARIES,      "promote_secondaries" },
>> +     { CTL_INT,      NET_IPV4_CONF_IGNORE_ROUTES_WITH_LINKDOWN,      "ignore_routes_with_linkdown" },
>>       {}
>>  };
>>
>
> Please do not add new binary sysctl knob. Thank you.

Reason?
