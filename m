From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [net-2.6 PATCH 6/10] Neterion: New driver: Hardware init & configuration
Date: Tue, 17 Mar 2009 11:52:30 +0100
Message-ID: <20090317105230.GP11935@one.firstfloor.org>
References: <1237018885.4966.431.camel@flash> <87bps12b33.fsf@basil.nowhere.org> <78C9135A3D2ECE4B8162EBDCE82CAD7705092E88@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
To: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56598 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812AbZCQKwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 06:52:08 -0400
Content-Disposition: inline
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7705092E88@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2009 at 11:25:19PM -0400, Ramkrishna Vepa wrote:
> Question of the following -
> > In general your driver looks like it could use a pass with sparse's
> > __iomem checking (make V=1)
> How do I enable this checking?

Install sparse and then

make V=1

and add __iomem annotations as needed.

There will be a lot of warnings, it's likely enough to concentrate on
iomem first pass.

-Andi
