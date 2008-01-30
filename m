From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii  matching table
Date: Wed, 30 Jan 2008 07:16:52 +0100
Message-ID: <200801300716.52463.sr@denx.de>
References: <1200476230-14026-1-git-send-email-sr@denx.de> <1200477239.6755.21.camel@pasglop> <20080116090110.1b7b2f00@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Josh Boyer <jwboyer@linux.vnet.ibm.com>, netdev@vger.kernel.org
To: linuxppc-dev@ozlabs.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:62778 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900AbYA3GRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 01:17:14 -0500
In-Reply-To: <20080116090110.1b7b2f00@zod.rchland.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 16 January 2008, Josh Boyer wrote:
> On Wed, 16 Jan 2008 20:53:59 +1100
>
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> > On Wed, 2008-01-16 at 10:37 +0100, Stefan Roese wrote:
> > > With the removal the the "rgmii-interface" device_type property from
> > > the dts files, the newemac driver needs an update to only rely on
> > > compatible property.
> > >
> > > Signed-off-by: Stefan Roese <sr@denx.de>
> >
> > I need to test if it works on CAB, can't change the DT on those. I'll
> > let you know tomorrow.
>
> This should be fine on CAB.  The rgmii node has:
>
> compatible = "ibm,rgmii-axon", "ibm,rgmii"
>
> so the match should still catch on the latter.

How about this patch? Ben, if you think this is ok then we should make sure 
that it goes in in this merge-window, since the other dts patch relies on it.

Thanks.

Best regards,
Stefan
