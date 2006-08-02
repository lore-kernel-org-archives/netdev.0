From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Wed, 2 Aug 2006 09:42:23 +0200
Message-ID: <20060802074223.GA23715@xi.wantstofly.org>
References: <44CDD631.5030008@snapgear.com> <20060731091423.3327f85e@dxpl.pdx.osdl.net> <44CEAB31.5090501@snapgear.com> <20060731220822.444f04e4@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philip Craig <philipc@snapgear.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:15564 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1750858AbWHBHmZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 03:42:25 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060731220822.444f04e4@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 10:08:22PM -0700, Stephen Hemminger wrote:

> > > Why not use existing bridge code?
> > 
> > It does use the existing bridge code.  Perhaps the name is misleading.
> > All it does is encapsulate the full ethernet header in a gre packet,
> > rather than only layer 3.  That is, currently gre uses ARPHRD_IPGRE,
> > but bridging requires ARPHRD_ETHER.
> 
> I am not against making the bridge code smarter to handle other
> encapsulation.

What if you want to run ethernet directly over a GRE tunnel, without
using bridging?
