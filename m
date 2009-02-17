From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: problem with IPoA (CLIP),  NAT, and VLANS
Date: Tue, 17 Feb 2009 13:37:07 +0000
Message-ID: <20090217133707.GA6802@ff.dom.local>
References: <20090216232016.GA4803@ami.dom.local> <499AA433.8070308@hiramoto.org> <20090217122052.GB6130@ff.dom.local> <499AB345.3070904@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:51495 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbZBQNhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 08:37:15 -0500
Content-Disposition: inline
In-Reply-To: <499AB345.3070904@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 17, 2009 at 01:53:25PM +0100, Karl Hiramoto wrote:
> Jarek Poplawski wrote:
> > On Tue, Feb 17, 2009 at 12:49:07PM +0100, Karl Hiramoto wrote:
> > ...
> >   
> >> A side note:  so far the original patch i sent works in all cases i have
> >> tested, but fails with tcpdump.   I suspect its because the skb gets cloned.

Hmm... I would like to make sure: if tcpdump breaks it too, then
we don't need to blame skb_cow_head(), do we? If it's like this then
it looks like the driver's problem with copied/cloned skbs?! (Maybe
because some "private" offset is overwritten?)

Jarek P.
