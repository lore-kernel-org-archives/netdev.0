From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 16:58:15 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0606131657050.14789@yvahk01.tjqt.qr>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from linux01.gwdg.de ([134.76.13.21]:23184 "EHLO linux01.gwdg.de")
	by vger.kernel.org with ESMTP id S1751133AbWFMO6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 10:58:19 -0400
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>+extern int kernel_ioctl(struct socket *sock, int cmd, unsigned long arg);
>+

I would prefer naming it kernel_sock_ioctl, since (general) ioctl often 
done on fds (or struct file * for that matter) rather than sockets.



Jan Engelhardt
-- 
