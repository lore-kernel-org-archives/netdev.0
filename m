From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [PATCH] NET: dmfe: don't access configuration space in D3 state
Date: Sat, 24 Nov 2007 05:48:27 +0200
Message-ID: <200711240548.28165.maximlevitsky@gmail.com>
References: <200711230129.02570.maximlevitsky@gmail.com> <200711230130.15939.maximlevitsky@gmail.com> <4747962D.5010506@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754429AbXKXDtL@vger.kernel.org>
In-Reply-To: <4747962D.5010506@garzik.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 24 November 2007 05:10:37 Jeff Garzik wrote:
> Maxim Levitsky wrote:
> >>From 7e24227257f315e52fe0b494dc1253d2a0ce5dff Mon Sep 17 00:00:00 2001
> > From: Maxim Levitsky <maximlevitsky@gmail.com>
> > Date: Fri, 23 Nov 2007 01:15:36 +0200
> > Subject: [PATCH] NET: dmfe: don't access configuration space in D3 state
> >  Accidently I reversed the order of pci_save_state and
> >  pci_set_power_state in .suspend()/.resume() callbacks
> > 
> > Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
> > ---
> >  drivers/net/tulip/dmfe.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> 
> applied #upstream-fixes, after hand-editing patch changelog taking by 
> git-am from email body
> 
> 
> 

Hi,

Thanks,
Next time I will be more careful with changelogs.

Best regards,
	Maxim Levitsky
