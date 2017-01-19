From: Paul Blakey <paulb@mellanox.com>
Subject: Re: [PATCH net-next V4] tc: flower: Refactor matching flags to be
 more user friendly
Date: Thu, 19 Jan 2017 16:29:34 +0200
Message-ID: <9b2c0b6b-0369-6588-ff17-a29a483942cb@mellanox.com>
References: <1484835468-46051-1-git-send-email-paulb@mellanox.com>
 <20170119152218.61aa2fc4@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <paulb@mellanox.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00072.outbound.protection.outlook.com ([40.107.0.72]:1664
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751458AbdASPGI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 10:06:08 -0500
In-Reply-To: <20170119152218.61aa2fc4@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 19/01/2017 16:22, Jiri Benc wrote:
> On Thu, 19 Jan 2017 16:17:48 +0200, Paul Blakey wrote:
>> +	while (token) {
>> +		if (!strncmp(token, "no", 2)) {
>> +			no = true;
>> +			token = strchr(token, '_') + 1;
>
> This seems to still assume that "no" is followed by an underscore.
> What about a simple token += 2?
>
>  Jiri
>

Thanks again, v5 is sent.
