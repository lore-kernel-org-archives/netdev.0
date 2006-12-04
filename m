From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC patch] driver for the Opencores Ethernet Controller
Date: Mon, 4 Dec 2006 19:07:36 +0100
Message-ID: <20061204180734.GA21561@xi.wantstofly.org>
References: <200612041801.kB4I11F4018165@oogie-boogie.ics.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:37337 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936608AbWLDSHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 13:07:45 -0500
To: Dan Nicolaescu <dann@ics.uci.edu>
Content-Disposition: inline
In-Reply-To: <200612041801.kB4I11F4018165@oogie-boogie.ics.uci.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 04, 2006 at 10:01:01AM -0800, Dan Nicolaescu wrote:

> The Opencores Ethernet Controller is Verilog code that can be used to
> implement an Ethernet device in hardware. It needs to be coupled with
> a PHY and some buffer memory. Because of that devices that implement
> this controller can be very different. The code here tries to support
> that by having some parameters that need to be defined at compile
> time.

Considering this, why don't you make it a platform driver?
