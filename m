From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [REVISED PATCH] 3c59x: check return of pci_enable_device()
Date: Fri, 31 Aug 2007 15:21:32 +0200
Message-ID: <20070831132132.GA2647@newton.mathematik.tu-chemnitz.de>
References: <200708102105.l7AL5Jje008968@imap1.linux-foundation.org> <20070814095432.GA13825@hindley.org.uk> <20070815163000.GB619@bayes.mathematik.tu-chemnitz.de> <20070816102840.GG14245@hindley.org.uk> <46D812D5.80904@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Hindley <mark@hindley.org.uk>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lana.hrz.tu-chemnitz.de ([134.109.132.3]:59635 "EHLO
	lana.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932646AbXHaNVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 09:21:35 -0400
Content-Disposition: inline
In-Reply-To: <46D812D5.80904@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 09:08:37AM -0400, Jeff Garzik wrote:
> Mark Hindley wrote:
> >Revised patch for this.
> >
> >Mark
> >
> >
> >commit 5cf33391eba81a49038fa8be8cbad8425b80bf7f
> >Author: Mark Hindley <mark@hindley.org.uk>
> >Date:   Thu Aug 16 11:26:35 2007 +0100
> >
> >    Check return of pci_enable_device in vortex_up().
> >    
> >    Also modify vortex_up to return error to callers. Handle failure of 
> >    vortex_up in
> >    vortex_open and vortex_resume.
> >    
> >    Signed-off-by: Mark Hindley <mark@hindley.org.uk>
> 
> Steffen, did you ACK this?  and/or going to resend it to me?
> 

Yes, I did. Andrew has it already in -mm, 
I guess that he will resend it to you soon.

Steffen
