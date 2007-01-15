From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: [patch 0/6] sky2 driver update (v1.11)
Date: Mon, 15 Jan 2007 20:12:11 +0100
Message-ID: <20070115191211.GA11018@dose.home.local>
References: <20061220210632.183204605@osdl.org> <459197B8.6010403@pobox.com> <20070101103644.02544c46@freekitty> <20070102191015.GA5758@dose.home.local> <20070113130329.GA9124@dose.home.local> <20070115102149.1ce12188@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:52223 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbXAOTMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 14:12:34 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20070115102149.1ce12188@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 15, 2007 at 10:21:49 -0800, Stephen Hemminger wrote:
> On Sat, 13 Jan 2007 14:03:29 +0100
> Tino Keitel <tino.keitel@tikei.de> wrote:
> 
> > On Tue, Jan 02, 2007 at 20:10:15 +0100, Tino Keitel wrote:
> > 
> > [...]
> > 
> > > Btw., I just built 2.6.20-rc3 with patches 4 and 5 and wake on LAN now
> > > works. Thanks for your work.
> > 
> > Hi,
> > 
> > I had some failures during resume from suspend with 2.6.20-rc3 and
> > -rc4. I enabled pm_trace and it looks like the sky2 driver is the
> > culprit:
> > 
> > hash matches drivers/base/power/resume.c:56
> > hash matches device 0000:01:00.0
> > 
> > $ lspci | grep 01:00.0
> > 01:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053
> > PCI-E Gigabit Ethernet Controller (rev 22)
> > 
> > I removed the patches and had no resume failure so far.
> > 
> > Regards,
> > Tino
> > 
> 
> What kind of failures, did the system just not come up?

Yes, screen stayed dark and machine was dead. However, it was hardly
reproducable. I set up a suspend/resume loop for an hour without
failures. Then, when I just wanted to suspend for a while, resume
failed.

> Did you have WOL enabled or not?

I had WOL enabled.

Regards,
Tino
