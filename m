From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 1/2] 8139too: Make PIO/MMIO a modparam
Date: Tue, 15 Jul 2008 19:15:43 -0400
Message-ID: <20080715231543.GB15266@redhat.com>
References: <20080429153240.7200e1a3.akpm@linux-foundation.org> <4818546C.4060703@garzik.org> <20080529150752.GB8247@redhat.com> <483EF385.3000103@garzik.org> <20080529184106.GB24408@redhat.com> <483EFD8F.2070407@garzik.org> <20080715184006.GA20772@redhat.com> <487D2236.9000903@garzik.org> <20080715225410.GB10532@redhat.com> <487D2CD6.2070303@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52278 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753387AbYGOXXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 19:23:24 -0400
Content-Disposition: inline
In-Reply-To: <487D2CD6.2070303@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2008 at 07:03:50PM -0400, Jeff Garzik wrote:
 
 > > +			pci_release_regions(pdev);
 > > +			use_ui = 1;
 > > +			goto retry;
 > 
 > use_ui?  Are you sure this is not not an X.org patch?  :)

heh, who needs compilers ?

 > Yes, seems like that would do the trick quite nicely...
 > 
 > If you would be kind enough to post this as a separate patch from your 
 > use_io patch (since IMO its a separate logical change), that would be 
 > helpful.

Sure, I'll repost the series in a bit.

	Dave

-- 
http://www.codemonkey.org.uk
