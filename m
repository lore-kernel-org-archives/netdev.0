From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: wan/x25_asy, move lapb_unregister to
 x25_asy_close_tty
Date: Sun, 28 Nov 2010 11:44:22 -0800 (PST)
Message-ID: <20101128.114422.233714708.davem@davemloft.net>
References: <1290642894-4577-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	andrew.hendry@gmail.com
To: jslaby@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56787
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752513Ab0K1Tn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 14:43:56 -0500
In-Reply-To: <1290642894-4577-1-git-send-email-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jslaby@suse.cz>
Date: Thu, 25 Nov 2010 00:54:54 +0100

> We register lapb when tty is created, but unregister it only when the
> device is UP. So move the lapb_unregister to x25_asy_close_tty after
> the device is down.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Reported-by: Sergey Lapin <slapin@ossfans.org>
> Cc: Andrew Hendry <andrew.hendry@gmail.com>

Applied with commit message addition you mentioned Jiri.

Thanks.
