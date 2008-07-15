From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 1/2] 8139too: Make PIO/MMIO a modparam
Date: Tue, 15 Jul 2008 19:40:37 -0400
Message-ID: <20080715234037.GA17417@redhat.com>
References: <20080529150752.GB8247@redhat.com> <483EF385.3000103@garzik.org> <20080529184106.GB24408@redhat.com> <483EFD8F.2070407@garzik.org> <20080715184006.GA20772@redhat.com> <487D2236.9000903@garzik.org> <20080715223626.GA10532@redhat.com> <487D2AEE.8030309@garzik.org> <20080715231457.GA15266@redhat.com> <487D3344.8000804@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751794AbYGOXs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 19:48:26 -0400
Content-Disposition: inline
In-Reply-To: <487D3344.8000804@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2008 at 07:31:16PM -0400, Jeff Garzik wrote:
 > Sorry for not being specific.  I would have guessed the uglier
 > 
 > 	#ifdef CONFIG_8139TOO_PIO
 > 		static int use_io = 1;
 > 	#else
 > 		static int use_io;
 > 	#endif
 > 
 > since CONFIG_8139TOO_PIO doesn't convert to a 1 or 0 neatly in C AFAIK?

Hm, yeah. that only works in the PIO=1 case. When not set, it doesn't
end up in autoconf.h.  I'll go with the fugly ifdefs.

	Dave

-- 
http://www.codemonkey.org.uk
