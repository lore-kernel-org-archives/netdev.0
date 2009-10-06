From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [net-next-2.6 PATCH 8/9] vxge: Acquire correct lock based on interrupt context.
Date: Mon, 5 Oct 2009 22:36:22 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705C16322@nekter>
References: <Pine.GSO.4.10.10910050757300.9377-100000@guinness> <20091005.053759.74765905.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:38843 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756004AbZJFChA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 22:37:00 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20091005.053759.74765905.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > - Added macros that check if the thread is in interrupt context or
not
> to
> >   acquire or release locks
> >
> > Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> 
> There is nothing at all wrong with using irqsave/irqrestore spin lock
> calls when you're already in an interrupt.
> 
> I don't see any reason for this change.
[Ram] Right, but why have the additional step of saving and restoring
the flags while in the interrupt context?

Ram
