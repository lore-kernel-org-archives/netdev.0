From: apgo@patchbomb.org (Arthur Othieno)
Subject: Re: [RFC: 2.6 patch] CONFIG_FORCEDETH updates
Date: Mon, 13 Feb 2006 03:36:35 -0500
Message-ID: <20060213083635.GD14516@krypton>
References: <20060212175202.GK30922@stusta.de> <1139781817.19342.300.camel@mindpipe>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751353AbWBMIkz@vger.kernel.org>
To: Lee Revell <rlrevell@joe-job.com>
Content-Disposition: inline
In-Reply-To: <1139781817.19342.300.camel@mindpipe>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 12, 2006 at 05:03:36PM -0500, Lee Revell wrote:
> On Sun, 2006-02-12 at 18:52 +0100, Adrian Bunk wrote:
> > This patch contains the following possible updates:
> > - let FORCEDETH no longer depend on EXPERIMENTAL
> > - remove the "Reverse Engineered" from the option text:
> >   for the user it's important which hardware the driver supports, not
> >   how it was developed
> 
> Is this driver as stable as one that was developed with proper
> documentation?

Been using it on nForce since v0.19 (circa 2003) with no problems.
I doubt there are that many (significant) users of the binary driver
left..

And like Alistair pointed out:

  drivers/net/forcedeth:17: * Copyright (c) 2004 NVIDIA Corporation

> I prefer to know that something as elementary as a fast ethernet
> controller had to be reverse engineered so I can avoid supporting
> a vendor so hostile to Linux.

Then how about moving the "Reverse Engineered" to the help text instead?
