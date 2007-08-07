From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.23 1/3]S2IO: Making MSIX as default intr_type
Date: Tue, 7 Aug 2007 18:59:11 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77020352FE@nekter>
References: <46B8F01B.1080308@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "Jeff Garzik" <jeff@garzik.org>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:6879 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753431AbXHGXCp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 19:02:45 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46B8F01B.1080308@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Go ahead and apply these patches to netdev#upstream (queued for 2.6.24).
Thanks,

Ram

> -----Original Message-----
> From: Jeff Garzik [mailto:jeff@garzik.org]
> Sent: Tuesday, August 07, 2007 3:20 PM
> To: Sivakumar Subramani
> Cc: netdev@vger.kernel.org; support
> Subject: Re: [PATCH 2.6.23 1/3]S2IO: Making MSIX as default intr_type
> 
> Sivakumar Subramani wrote:
> > - Making MSIX as default intr_type
> > - Driver will test MSI-X by issuing test MSI-X vector and if fails
it
> will
> >   fallback to INTA
> >
> > Signed-off-by: Sivakumar Subramani
<sivakumar.subramani@neterion.com>
> > Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> 
> This patch series looks a bit big to apply this far past the merge
> window.  It changes behavior in the middle of a -rc stream, which is
> something to avoid since we are deep into "bug fixes only" mode at
this
> point.
> 
> I'm open to suggestions, otherwise I can apply these to
netdev#upstream
> (queued for 2.6.24).
> 
> 	Jeff
> 

