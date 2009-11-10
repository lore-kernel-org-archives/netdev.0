From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] can: fix WARN_ON dump in net/core/rtnetlink.c:rtmsg_ifinfo()
Date: Tue, 10 Nov 2009 12:24:36 +0100
Message-ID: <4AF94D74.4040606@trash.net>
References: <4AF54389.1090309@grandegger.com> <20091108.004602.213063654.davem@davemloft.net> <4AF68FCB.4050103@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64905 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbZKJLYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 06:24:36 -0500
In-Reply-To: <4AF68FCB.4050103@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> David Miller wrote:
>> From: Wolfgang Grandegger <wg@grandegger.com>
>> Date: Sat, 07 Nov 2009 10:53:13 +0100
>>
>>> On older kernels, e.g. 2.6.27, a WARN_ON dump in rtmsg_ifinfo()
>>> is thrown when the CAN device is registered due to insufficient
>>> skb space, as reported by various users. This patch adds the
>>> rtnl_link_ops "get_size" to fix the problem. I think this patch
>>> is required for more recent kernels as well, even if no WARN_ON
>>> dumps are triggered. Maybe we also need "get_xstats_size" for
>>> the CAN xstats.
>>>
>>> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
>> Applied to net-2.6, thanks Wolfgang.
> 
> Thanks, the commit message included some questions. What is the rule
> using the rtnl_link_ops "get_size" or "get_xstats_size". Are these
> mandatory if the corresponding fill functions are used?

Yes. You also need a get_xstats_size() function.
