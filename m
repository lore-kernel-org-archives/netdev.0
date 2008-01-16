From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii
 matching table
Date: Wed, 16 Jan 2008 09:01:10 -0600
Message-ID: <20080116090110.1b7b2f00@zod.rchland.ibm.com>
References: <1200476230-14026-1-git-send-email-sr@denx.de>
	<1200477239.6755.21.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:36243 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751263AbYAPPDB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 10:03:01 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0GF2wtg029331
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 10:02:58 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0GF2k52421894
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 10:02:47 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0GF2iwH003364
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 08:02:46 -0700
In-Reply-To: <1200477239.6755.21.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Jan 2008 20:53:59 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> 
> On Wed, 2008-01-16 at 10:37 +0100, Stefan Roese wrote:
> > With the removal the the "rgmii-interface" device_type property from the
> > dts files, the newemac driver needs an update to only rely on compatible
> > property.
> > 
> > Signed-off-by: Stefan Roese <sr@denx.de>
> 
> I need to test if it works on CAB, can't change the DT on those. I'll
> let you know tomorrow.

This should be fine on CAB.  The rgmii node has:

compatible = "ibm,rgmii-axon", "ibm,rgmii"

so the match should still catch on the latter.

josh
