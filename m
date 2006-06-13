From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 09:27:27 -0700
Message-ID: <1150216047.31720.16.camel@w-sridhar2.beaverton.ibm.com>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com>
	 <Pine.LNX.4.61.0606131657050.14789@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:35014 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932178AbWFMQ2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 12:28:13 -0400
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
In-Reply-To: <Pine.LNX.4.61.0606131657050.14789@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-13 at 16:58 +0200, Jan Engelhardt wrote:
> >+extern int kernel_ioctl(struct socket *sock, int cmd, unsigned long arg);
> >+
> 
> I would prefer naming it kernel_sock_ioctl, since (general) ioctl often 
> done on fds (or struct file * for that matter) rather than sockets.

I agree that this is misleading.
My original preference was to use ksock_ prefix for all these wrapper
functions. But just to be consistent with the existing kernel_sendmsg
and kernel_recvmsg, i used kernel_ prefix.
If it is OK, i could rename them also to use the ksock_ prefix to make
them all consistent and also indicating that we are operating on sockets.
If not, i will go with kernel_sock_ioctl().

Thanks
Sridhar


