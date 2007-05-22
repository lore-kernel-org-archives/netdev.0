From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: [PATCH] e1000: Don't enable polling in open() (was: e1000: assertion
 hit in e1000_clean(), kernel 2.6.21.1)
Date: Tue, 22 May 2007 12:56:06 -0400
Message-ID: <465320A6.80706@redhat.com>
References: <20070521215134.14885.84952.stgit@localhost.localdomain> <46522E6F.9060600@garzik.org> <20070522010137.GC8130@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Auke Kok <auke-jan.h.kok@intel.com>,
	stable@vger.kernel.org, greg@suse.de,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davej@redhat.com
To: Herbert Xu <herbert.xu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40389 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760020AbXEVQ4a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 12:56:30 -0400
In-Reply-To: <20070522010137.GC8130@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, May 21, 2007 at 07:42:39PM -0400, Jeff Garzik wrote:
>> applied, though as a poster (DaveJ?) noted, I'm not sure it completely 
>> fixes the bug
> 
> It should fix the problem completely in 2.6.22.  For 2.6.21, we need
> a different fix because e1000_open is directly calling e1000_up.
> 

Is there going to be a 2.6.21-stable fix for this?

Fedora is going to backport a big patchset but that won't work
for -stable.
