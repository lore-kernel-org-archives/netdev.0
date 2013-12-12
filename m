From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 0/2] Display adjacent switch port's attributes
Date: Thu, 12 Dec 2013 11:06:46 +0100
Message-ID: <52A98AB6.3060405@6wind.com>
References: <1386768540-48188-1-git-send-email-raspl@linux.vnet.ibm.com> <20131211121357.4742d9e8@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	blaschka@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:56625 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120Ab3LLKGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 05:06:51 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so178632wgh.2
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 02:06:50 -0800 (PST)
In-Reply-To: <20131211121357.4742d9e8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/12/2013 21:13, Stephen Hemminger a =E9crit :
> On Wed, 11 Dec 2013 14:28:58 +0100
> Stefan Raspl <raspl@linux.vnet.ibm.com> wrote:
>
>> This patch series adds a new callback for ethtool to display the adj=
acent switch
>> port's attributes, as perceived by the NIC, e.g. through respective =
LLDP message
>> exchanges.
>> A patch for the qeth device driver provides a sample exploiter for t=
he new
>> functionality.
>> A new option for ethtool to display the settings will be posted in a=
 separate
>> patch.
>>
>> Best regards,
>> Stefan Raspl
>>
>> Stefan Raspl (2):
>>    ethtool: Add callback to indicate adjacent switch port attributes
>>    qeth: Display adjacent switch port attributes in ethtool
>>
>>   drivers/s390/net/qeth_core.h      |  7 ++++
>>   drivers/s390/net/qeth_core_main.c | 79 +++++++++++++++++++++++++++=
++++++++++++
>>   drivers/s390/net/qeth_core_mpc.h  | 17 +++++++++
>>   drivers/s390/net/qeth_l2_main.c   |  1 +
>>   drivers/s390/net/qeth_l3_main.c   |  1 +
>>   include/linux/ethtool.h           |  3 ++
>>   include/uapi/linux/ethtool.h      | 35 +++++++++++++++++
>>   net/core/ethtool.c                | 22 +++++++++++
>>   8 files changed, 165 insertions(+)
>>
>
> Why more ethtool and not netlink? ethtool is a brittle interface, non=
-extensible
> and does not support notifications of changes.
I agree with Stephen, netlink has more pros.
