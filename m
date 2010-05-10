From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Pull request: bluetooth-next-2.6 2010-05-10
Date: Mon, 10 May 2010 13:26:13 +0200
Message-ID: <1273490773.375.39.camel@localhost.localdomain>
References: <cover.1273484094.git.marcel@holtmann.org>
	 <20100510.042031.135962157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:45911 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab0EJL0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 07:26:51 -0400
In-Reply-To: <20100510.042031.135962157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> Ok, I pulled this.
> 
> But patch #32 needs to be fixed.  That TX window thing is, if
> anything, a socket option not some obscure module load parameter.
> 
> Doing it with a module parameter means that you can't make it so that
> only some sockets (or some network paths) use a certain TX window
> value and other's not.
> 
> Another alternative is to, as implied, make it a route metric or
> similar.
> 
> Anything but a module option is appropriate for this.

actually that was only a module option so we can easily test this at an
UnPlugFest. I think it can be removed all together now. We don't need it
anymore. I check with Gustavo.

Regards

Marcel


