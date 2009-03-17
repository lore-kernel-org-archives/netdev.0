From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-2.6 PATCH 6/10] Neterion: New driver: Hardware init &
	configuration
Date: Tue, 17 Mar 2009 03:34:42 +0000
Message-ID: <1237260883.9656.23.camel@bunthorne.i.decadent.org.uk>
References: <1237018885.4966.431.camel@flash>
	 <87bps12b33.fsf@basil.nowhere.org>
	 <78C9135A3D2ECE4B8162EBDCE82CAD7705092E88@nekter>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51607 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751924AbZCQDew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 23:34:52 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7705092E88@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-03-16 at 23:25 -0400, Ramkrishna Vepa wrote:
> Andi,
> 
> Thanks for the comments. We are looking into them.
> 
> Question of the following -
> > In general your driver looks like it could use a pass with sparse's
> > __iomem checking (make V=1)
> How do I enable this checking?

What Andi said, only without the typo: run "make C=1 drivers/net/vxge/"

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
