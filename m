From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] drivers/net/r6040.c: Eliminate double sizeof
Date: Fri, 27 Jun 2008 01:33:30 -0400
Message-ID: <48647BAA.8060308@pobox.com>
References: <Pine.LNX.4.64.0806232311570.13402@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: florian.fainelli@telecomint.eu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56727 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752576AbYF0Fdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:33:37 -0400
In-Reply-To: <Pine.LNX.4.64.0806232311570.13402@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> Taking sizeof the result of sizeof is quite strange and does not seem to be
> what is wanted here.
> 
> This was fixed using the following semantic patch.
> (http://www.emn.fr/x-info/coccinelle/)
> 
> // <smpl>
> @@
> expression E;
> @@
> 
> - sizeof (
>   sizeof (E)
> - )
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

applied


