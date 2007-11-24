From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.24 1/1]S2io: Fixed memory leak by freeing MSI-X local entry memories when vector allocation fails
Date: Sat, 24 Nov 2007 00:48:31 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD770295248A@nekter>
References: <4747947F.80506@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "Jeff Garzik" <jeff@garzik.org>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:50610 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741AbXKXFtL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2007 00:49:11 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4747947F.80506@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

We got an ACK back last week from Dave Miller that the following 2
patches were already applied - reply follows.

" > [Ram] The version numbers are different for the 2 patches. Was the 
> MSI-X leak bug fix applied prior to resubmission (we had swapped the 
> version numbers on the patches for resubmission).
> 
> [PATCH 2.6.24 1/1]S2io: Fixed memory leak by freeing MSI-X local entry

> memories when vector allocation fails
> +#define DRV_VERSION "2.0.26.6"
> 
> [PATCH 2.6.24 1/1]S2io: Support for add/delete/store/restore ethernet 
> addresses
> +#define DRV_VERSION "2.0.26.7"

I applied only the leak fix to the stable branch, and only the ethernet
address support patch to the 2.6.25 development tree.

The bug fix will show up later when the 2.6.25 development tree gets
rebased to upstream (which will have the leak fix by then).

This is how I do things, and that's why changing the DRV_VERSION to
2.0.26.7 made no sense.

Therefore it makes the most sense to bump driver version numbers only
when things are entirely self contained."

Ram
> -----Original Message-----
> From: Jeff Garzik [mailto:jeff@garzik.org]
> Sent: Friday, November 23, 2007 7:03 PM
> To: Sreenivasa Honnur
> Cc: netdev@vger.kernel.org; support
> Subject: Re: [PATCH 2.6.24 1/1]S2io: Fixed memory leak by freeing
MSI-X
> local entry memories when vector allocation fails
> 
> Sreenivasa Honnur wrote:
> > - Fixed memory leak by freeing MSI-X local entry memories when
vector
> allocation
> > fails in s2io_add_isr.
> > - Added two utility functions remove_msix_isr and remove_inta_isr to
> eliminate
> > code duplication.
> > - Incorporated following review comments from Jeff
> >         - Removed redundant stats->mem_freed and synchronize_irq
call
> >         - do_rem_msix_isr is renamed as remove_msix_isr
> >         - do_rem_inta_isr is renamed as remove_inta_isr
> >
> > - (Resubmit third time)
> 
> ditto, does not apply
> 

