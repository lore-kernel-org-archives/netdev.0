From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][VLAN] Lost rtnl_unlock() in vlan_ioctl()
Date: Thu, 06 Dec 2007 14:59:24 +0100
Message-ID: <4758003C.9080105@trash.net>
References: <4757FE80.2080000@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64445 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbXLFN7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 08:59:55 -0500
In-Reply-To: <4757FE80.2080000@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> The SET_VLAN_NAME_TYPE_CMD command w/o CAP_NET_ADMIN capability
> doesn't release the rtnl lock.


Thanks Pavel. I somehow recall that we already fixed this
one, but can't find the patch :) Dave, please apply.

