From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: r8169 tx problem (1s pause with ping)
Date: Mon, 18 Jun 2007 11:14:30 -0400
Message-ID: <20070618151430.GE10418@kvack.org>
References: <20070613004154.GA4187@kvack.org> <20070613211859.GA22521@electric-eye.fr.zoreil.com> <46715FBA.3070302@iinet.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Gundersen <gundy@iinet.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:36254 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932134AbXFRPOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2007 11:14:42 -0400
Content-Disposition: inline
In-Reply-To: <46715FBA.3070302@iinet.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 15, 2007 at 01:33:14AM +1000, David Gundersen wrote:
> In the mean-time I'll attach my patch for the r8168-8.001.00 realtek 
> driver here in case anybody else wants to have a play with it and see if 
> it helps them out.

Out of curiousity, does it work if you just do a single read (ie 
RTL_R8(TxPoll);) of the register before writing to it?  That would clear 
things up if it is a PCI posting problem.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
