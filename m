From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/11] inet_diag: Partly rename inet_ to sock_
Date: Tue, 06 Dec 2011 13:42:02 -0500 (EST)
Message-ID: <20111206.134202.1463574805110883510.davem@davemloft.net>
References: <4EDE573A.6040607@parallels.com>
	<4EDE575B.3010507@parallels.com>
	<20111206102447.25cc60f4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab1LFSmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 13:42:06 -0500
In-Reply-To: <20111206102447.25cc60f4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 6 Dec 2011 10:24:47 -0800

> On Tue, 06 Dec 2011 21:56:43 +0400
> Pavel Emelyanov <xemul@parallels.com> wrote:
> 
>> diff --git a/include/linux/netlink.h b/include/linux/netlink.h
>> index 8374d29..9827ebf 100644
>> --- a/include/linux/netlink.h
>> +++ b/include/linux/netlink.h
>> @@ -8,7 +8,7 @@
>>  #define NETLINK_UNUSED		1	/* Unused number				*/
>>  #define NETLINK_USERSOCK	2	/* Reserved for user mode socket protocols 	*/
>>  #define NETLINK_FIREWALL	3	/* Firewalling hook				*/
>> -#define NETLINK_INET_DIAG	4	/* INET socket monitoring			*/
>> +#define NETLINK_SOCK_DIAG	4	/* socket monitoring				*/
>>  #define NETLINK_NFLOG		5	/* netfilter/iptables ULOG */
>>  #define NETLINK_XFRM		6	/* ipsec */
>>  #define NETLINK_SELINUX		7	/* SELinux event notifications */
> 
> This is a header file that is stripped and exported by other
> tools. You can add new entries but need to keep existing define's
> to avoid breaking source compatibility.

Indeed, NETLINK_INET_DIAG must be kept around forever because that's what userland
source code references.

I'll fix this up when applying Pavel's patches, by simply adding a new alias that
userland can start being coverted over to use.
