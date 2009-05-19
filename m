From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Wed, 20 May 2009 07:56:42 +1000
Message-ID: <1242770202.16901.116.camel@pasglop>
References: <1241640919-4650-1-git-send-email-wd@denx.de>
	 <fa686aa40905140700k3ca28ac0m74c9c161ad538abc@mail.gmail.com>
	 <1242685051.16901.6.camel@pasglop>  <200905191326.29122.kosmo@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Wolfgang Denk <wd@denx.de>,
	Scott Wood <scottwood@freescale.com>,
	John Rigby <jrigby@gmail.com>, linuxppc-dev@ozlabs.org,
	Detlev Zundel <dzu@denx.de>, netdev@vger.kernel.org,
	Kumar Gala <galak@kernel.crashing.org>,
	Becky Bruce <Becky.Bruce@freescale.com>
To: Piotr =?UTF-8?Q?Zi=C4=99cik?= <kosmo@semihalf.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53265 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbZESV7P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 17:59:15 -0400
In-Reply-To: <200905191326.29122.kosmo@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-05-19 at 13:26 +0200, Piotr Zi=C4=99cik wrote:
> Tuesday 19 May 2009 00:17:31 Benjamin Herrenschmidt wrote:
> >
> > We are close to the point where we can make this a runtime option
> > though, by just having a different set of dma_ops hooked in.
> >
>=20
> Is somebody currently working on it? If yes, where we can see
> code ?

Well, the current upstream code has the dma ops support. Becky is
massaging that more for swiotlb support which has been submitted to the
linuxppc-dev list. We haven't yet added runtime support rather than
compile time for non-cache coherent platforms, but it's becoming
reasonably easy to add now (though still needs to be done).

Cheers,
Ben

