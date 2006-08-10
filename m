From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Thu, 10 Aug 2006 15:09:20 +0200
Message-ID: <20060810130920.GH17652@xi.wantstofly.org>
References: <44CEAB31.5090501@snapgear.com> <20060731220822.444f04e4@localhost.localdomain> <20060802074223.GA23715@xi.wantstofly.org> <44D15265.4090905@snapgear.com> <20060803073307.GA29775@xi.wantstofly.org> <44D1BE93.1080308@snapgear.com> <20060803194016.GC527@xi.wantstofly.org> <44D29C47.6080407@snapgear.com> <20060804080236.GA4106@xi.wantstofly.org> <44D69D82.1090407@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:64407 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1161504AbWHJNJY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 09:09:24 -0400
To: Philip Craig <philipc@snapgear.com>
Content-Disposition: inline
In-Reply-To: <44D69D82.1090407@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 11:55:14AM +1000, Philip Craig wrote:

> > I have one machine at home that appears to be on my employer's network
> > via such a tunnel.  I don't use bridging, because I don't need any other
> > machine at home to access this tunnel.  I do want bridging, and not proxy
> > ARP, because it allows me to run arpwatch, and doesn't require me to
> > reconfigure something at the remote end if I, for example, want to add
> > another IP address to my home box.
> 
> Okay.
> If this is using Linux, do you have a patch that does this already?

I use vtun:

	http://vtun.sourceforge.net/

But I would prefer using some in-kernel ethernet tunneling method with
ipsec instead.
