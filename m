From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Make simple TX hash little endian safe.
Date: Mon, 21 Jul 2008 17:17:13 +0200
Message-ID: <20080721151713.GB29543@basil.nowhere.org>
References: <1216630088-10328-1-git-send-email-andi@firstfloor.org> <20080721123215.GA4376@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:26141 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756750AbYGUPSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 11:18:04 -0400
Content-Disposition: inline
In-Reply-To: <20080721123215.GA4376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2008 at 12:32:15PM +0000, Jarek Poplawski wrote:
> On 21-07-2008 10:48, Andi Kleen wrote:
> > From: Andi Kleen <andi@basil.nowhere.org>
> > 
> > Currently it will not use the lower
> > bits at all on big endian system, mapping e.g. all connections to a single
> > queue on a local network which only differs in the low bits.
> 
> It seems ports could be treated similarly, btw?

Ports should be normally better distributed because they tend
to be more uniform than IP addresses due to the way they are
generated, so there will hopefully not be too many endian artifacts. 
But yes at least least folding them too might be a good idea.

-Andi
