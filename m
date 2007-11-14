From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.24 1/1]S2io: Support for add/delete/store/restore ethernet addresses
Date: Wed, 14 Nov 2007 18:08:33 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD770289BAF6@nekter>
References: <20071114.145559.170046831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	<netdev@vger.kernel.org>, <jeff@garzik.org>,
	"support" <support@neterion.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:27519 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752298AbXKNXIg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 18:08:36 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071114.145559.170046831.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Got it. Thanks,

Ram
> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, November 14, 2007 2:56 PM
> To: Ramkrishna Vepa
> Cc: Sreenivasa Honnur; netdev@vger.kernel.org; jeff@garzik.org;
support
> Subject: Re: [PATCH 2.6.24 1/1]S2io: Support for
add/delete/store/restore
> ethernet addresses
> 
> From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
> Date: Wed, 14 Nov 2007 15:57:23 -0500
> 
> > [Ram] The version numbers are different for the 2 patches. Was the
MSI-X
> > leak bug fix applied prior to resubmission (we had swapped the
version
> > numbers on the patches for resubmission).
> >
> > [PATCH 2.6.24 1/1]S2io: Fixed memory leak by freeing MSI-X local
entry
> > memories when vector allocation fails
> > +#define DRV_VERSION "2.0.26.6"
> >
> > [PATCH 2.6.24 1/1]S2io: Support for add/delete/store/restore
ethernet
> > addresses
> > +#define DRV_VERSION "2.0.26.7"
> 
> I applied only the leak fix to the stable branch, and only
> the ethernet address support patch to the 2.6.25 development
> tree.
> 
> The bug fix will show up later when the 2.6.25 development
> tree gets rebased to upstream (which will have the leak
> fix by then).
> 
> This is how I do things, and that's why changing the DRV_VERSION
> to 2.0.26.7 made no sense.
> 
> Therefore it makes the most sense to bump driver version numbers
> only when things are entirely self contained.
> 

