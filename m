From: Gerd Hoffmann <kraxel@redhat.com>
Subject: Re: netfront for review
Date: Thu, 03 May 2007 17:38:31 +0200
Message-ID: <463A01F7.90500@redhat.com>
References: <4637D672.5030706@goop.org> <1178077033.28659.173.camel@localhost.localdomain> <4638EAC0.7020107@goop.org> <46399057.4000409@redhat.com> <20070503151756.GA29629@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>,
	Gerd Hoffmann <kraxel@redhat.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45409 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946180AbXECPmt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 11:42:49 -0400
In-Reply-To: <20070503151756.GA29629@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Thu, May 03, 2007 at 09:33:43AM +0200, Gerd Hoffmann wrote:
>>> Guess so.  It defaults to flip.  I simplified the rx_copy/flip module
>>> parameter to a simple rx_mode=0/1, but this is preserved from the
>>> original.  My guess is that originally there was only flip, and copy was
>>> added later.
>> Yep, page flipping is the old (pre xen 3.0.3) way, copy was added (and 
>> made the default) later.
> 
> So can we please just rip out the obsolete code completely?  There's
> no point adding this code anymore.

Drawback is that the guest kernel wouldn't work with older xen versions 
(dom0 netback driver to be exact) any more.  Probably wouldn't be a 
showstopper though, given that xen 3.0.3 probably is almost one year out 
by the time 2.6.22 will be released ...
