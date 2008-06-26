From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 2.6.25.3 1/5] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Thu, 26 Jun 2008 07:59:07 +0200
Message-ID: <20080626055907.GD1369@1wt.eu>
References: <72981EBCFD196144B7C6999B9FC34A9A3EE603B863@SHEXMB-01.global.atheros.com> <20080625224829.3c6f4789@extreme> <20080625.225550.199765051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, Jie.Yang@Atheros.com, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2088 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550AbYFZF7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 01:59:19 -0400
Content-Disposition: inline
In-Reply-To: <20080625.225550.199765051.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2008 at 10:55:50PM -0700, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 25 Jun 2008 22:48:29 -0700
> 
> > I would prefer that the driver be NAPI only, because configuration
> > choices are hard for users and distribution to make correct
> > choice. Plus it means two choices for your QA to test.
> 
> I agree with Stephen.
> 
> It's absolutely to provide a non-NAPI option, please just remove
> the option and the conditionals from the code.

Also I think it's useless to provide one patch per source file. It'd
be better to have one whole patch, or several ones if some features
may be added incrementally.

Willy

