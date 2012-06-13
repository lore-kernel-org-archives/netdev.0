From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: PPPoE performance regression
Date: Wed, 13 Jun 2012 13:21:22 -0400
Message-ID: <20120613172122.GF2361@kvack.org>
References: <1339144954.24571.80.camel@dualcore.traverse> <1339147045.13998.3.camel@i7.infradead.org> <1339289425.2661.27.camel@laptop> <1339317136.2851.54.camel@shinybook.infradead.org> <1339581421.11011.18.camel@shinybook.infradead.org> <1339595401.11011.48.camel@shinybook.infradead.org> <20120613155541.GD2361@kvack.org> <1339603894.14785.5.camel@shinybook.infradead.org> <20120613163108.GE2361@kvack.org> <1339606383.14785.14.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nathan Williams <nathan@traverse.com.au>,
	Karl Hiramoto <karl@hiramoto.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	John Crispin <blogic@openwrt.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:57405 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371Ab2FMRVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 13:21:24 -0400
Content-Disposition: inline
In-Reply-To: <1339606383.14785.14.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 13, 2012 at 05:53:03PM +0100, David Woodhouse wrote:
> I'm looking at the class of device on which OpenWRT runs. Linux is *on*
> the router with the ADSL port, not connected to it via Ethernet.

Ah, yes, that's a worthwhile pursuit.

> And even if it *were* rare... this is the case that *should* work best,
> where we have complete control of the hardware. There's no excuse for
> the behaviour that we currently see with PPPoE on BR2684.

*nod*

> I think that's largely true of BQL in general, isn't it? That's OK; it's
> a config option. I suspect if I make this accounting of PPPoE / L2TP
> packets conditional on BQL (or perhaps on a separate config option
> PPP_BQL) that ought to address your concern about the cases where you
> don't need it?

That would help.

On the whole question of PPPoE over intermediate ethernet links to ADSL 
modems, I think it would be possible to limit latency by implementing a 
sliding window clocked using LCP ECHO requests.  Does this sound worthwhile 
implementing?  What sort of queue depths are you looking at for the ATM 
devices you're working on?

		-ben
-- 
"Thought is the essence of where you are now."
