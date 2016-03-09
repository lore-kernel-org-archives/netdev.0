From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Question on switchdev
Date: Wed, 9 Mar 2016 01:39:19 +0100
Message-ID: <20160309003919.GA31963@lunn.ch>
References: <56D4BB74.2010109@ti.com>
 <20160229222934.GA4904@lunn.ch>
 <56D8BB61.5020500@ti.com>
 <56DE0A36.9090807@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, sfeldma@gmail.com, netdev@vger.kernel.org
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52991 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752826AbcCIAjY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 19:39:24 -0500
Content-Disposition: inline
In-Reply-To: <56DE0A36.9090807@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Andrew,
> 
> >From the high level, it looks like netcp switch meets the specifications
> of a DSA hardware. Can you point me to a specific implementation that
> I can use as an example to implement this for netcp?

You need two parts:

A tagging implementation, in net/dsa/tag_*.c. They are all pretty
similar, and all pretty simple.

A switch driver. driver/net/dsa/mv88e6060.c is the simplest. I would
suggest your first submission implements similar features as to what
this driver does. This is very minimalistic, but a good start. Once
that is accepted, you can incrementally add more features.

     Andrew
