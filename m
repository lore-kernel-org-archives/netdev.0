From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Don't attach callback to a going-away netlink socket
Date: Mon, 16 Apr 2007 13:41:54 +0200
Message-ID: <46236102.2080706@trash.net>
References: <46236082.3000101@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	devel@openvz.org, Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelianov <xemul@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38267 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030476AbXDPLoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 07:44:04 -0400
In-Reply-To: <46236082.3000101@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> From: Denis Lunev <den@openvz.org>
> 
> There is a race between netlink_dump_start() and netlink_release()
> that can lead to the situation when a netlink socket with non-zero
> callback is freed.


Can you describe the race in more detail please?

