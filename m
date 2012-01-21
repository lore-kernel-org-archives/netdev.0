From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH] enic: fix compile when CONFIG_PCI_IOV is not
 enabled
Date: Sat, 21 Jan 2012 00:03:38 -0800
Message-ID: <CB3FB15A.414F9%roprabhu@cisco.com>
References: <20120120.134005.1489924902535382966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <rdunlap@xenotime.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-2.cisco.com ([173.36.130.13]:50360 "EHLO
	mtv-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab2AUIDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2012 03:03:41 -0500
In-Reply-To: <20120120.134005.1489924902535382966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On 1/20/12 10:40 AM, "David Miller" <davem@davemloft.net> wrote:

> From: Roopa Prabhu <roprabhu@cisco.com>
> Date: Fri, 20 Jan 2012 00:25:36 -0800
> 
>> From: Roopa Prabhu <roprabhu@cisco.com>
>> 
>> reverting back change that access enic->num_vfs outside
>> CONFIG_PCI_IOV
>> 
>> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
>> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> 
> Applied, thanks.
> 
> I don't see how you can be asking this to be applied to the net-next
> tree.  I applied your patches to the plain 'net' tree and therefore
> this patch won't apply to net-next at all, go and see for yourself
> if you don't believe me. :-)

Ah..:). I looked for my patches in net-next... And did not find them. did
not realize why.. I wanted to get the patch out soon and had very little
time at hand, so created it on top of my net-next clone that had my previous
patches applied. Thanks for applying it to the correct tree. 
