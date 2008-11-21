From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH netdev-2.6] jme: JMicron Gigabit Ethernet Driver
Date: Sat, 22 Nov 2008 00:22:14 +0800
Message-ID: <20081121161840.M52663@cooldavid.org>
References: <20081120212045.27879d22@extreme> <20081120.213627.210066076.davem@davemloft.net> <20081120224542.10feb72d@extreme> <20081121.004633.193696042.davem@davemloft.net>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Cc: akeem@jmicron.com, ethanhsiao@jmicron.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:51453 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754017AbYKUQe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 11:34:27 -0500
In-Reply-To: <20081121.004633.193696042.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Nov 2008 00:46:33 -0800 (PST), David Miller wrote
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 20 Nov 2008 22:45:42 -0800
> 
> > On Thu, 20 Nov 2008 21:36:27 -0800 (PST)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Stephen Hemminger <shemminger@vyatta.com>
> > > Date: Thu, 20 Nov 2008 21:20:45 -0800
> > > 
> > > > 6. Not using pci dma allocation which is more standard convention
> > > 
> > > Using the generic DMA interfaces is actually preferred.  There is
> > > no effective difference other than using a more generic interface.
> > 
> > Ok, but this???
> 
> Yes, of course, all of those NAPI et al. abstraction macros have
> to go.
> 
> I was only commenting about the DMA bits, the rest of your
> criticism was on target.
Thank you for point those out.
This is my first driver, so I still have many things to learn.
I'll work on it. Any suggestion or help is very welcome!

Guo-Fu Tseng

