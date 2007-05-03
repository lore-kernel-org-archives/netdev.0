From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: netfront for review
Date: Thu, 03 May 2007 09:00:48 -0700
Message-ID: <463A0730.8070007@goop.org>
References: <4637D672.5030706@goop.org> <1178077033.28659.173.camel@localhost.localdomain> <4638EAC0.7020107@goop.org> <46399057.4000409@redhat.com> <20070503151756.GA29629@infradead.org> <463A01F7.90500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:48132 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162153AbXECQAv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 12:00:51 -0400
In-Reply-To: <463A01F7.90500@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gerd Hoffmann wrote:
> Drawback is that the guest kernel wouldn't work with older xen
> versions (dom0 netback driver to be exact) any more.  Probably
> wouldn't be a showstopper though, given that xen 3.0.3 probably is
> almost one year out by the time 2.6.22 will be released ...

I don't think we've decided how backwards-compatible the pv_ops guest
should be.  I've been working on the basis "as much as possible", so
long as it isn't a large burden.

    J
