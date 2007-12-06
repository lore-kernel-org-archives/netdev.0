From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][VLAN] Lost rtnl_unlock() in vlan_ioctl()
Date: Thu, 06 Dec 2007 15:10:35 +0100
Message-ID: <475802DB.1070807@trash.net>
References: <4757FE80.2080000@openvz.org>	<4758003C.9080105@trash.net> <20071206.060151.154858451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64834 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbXLFOLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 09:11:10 -0500
In-Reply-To: <20071206.060151.154858451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 06 Dec 2007 14:59:24 +0100
> 
>> Pavel Emelyanov wrote:
>>> The SET_VLAN_NAME_TYPE_CMD command w/o CAP_NET_ADMIN capability
>>> doesn't release the rtnl lock.
>>
>> Thanks Pavel. I somehow recall that we already fixed this
>> one, but can't find the patch :) Dave, please apply.
> 
> I think we even added this bug to -stable, or something like
> that, didn't we?  Yikes...


No, I mixed those two patches up as well. The bug was introduced
with the vlan_netlink stuff, the -stable patch fixed an invalid
return value, but still properly dropped the lock.

This patch should of course go in -stable anyway.


