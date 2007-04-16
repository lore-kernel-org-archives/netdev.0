From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Don't attach callback to a going-away netlink socket
Date: Mon, 16 Apr 2007 14:55:08 +0200
Message-ID: <4623722C.40009@trash.net>
References: <46236082.3000101@sw.ru> <46236102.2080706@trash.net> <462364D2.6010700@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	devel@openvz.org, Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelianov <xemul@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39698 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030521AbXDPMzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 08:55:11 -0400
In-Reply-To: <462364D2.6010700@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> Patrick McHardy wrote:
> 
>>>There is a race between netlink_dump_start() and netlink_release()
>>>that can lead to the situation when a netlink socket with non-zero
>>>callback is freed.
>>
>>
>>Can you describe the race in more detail please?
>>
> 
> Here it is:
> 
> [...]
> The proposal it to make sock_orphan before detaching the callback
> in netlink_release() and to check for the sock to be SOCK_DEAD in
> netlink_dump_start() before setting a new callback.


Thanks, good catch. Your patch also looks good.

Acked-by: Patrick McHardy <kaber@trash.net>

