From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 10 Oct 2007 08:35:31 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903C0883E@orsmsx414.amr.corp.intel.com>
References: <20071010091644.GA9807@one.firstfloor.org><20071010.022550.21928751.davem@davemloft.net><20071010102331.GA10496@one.firstfloor.org> <20071010.034446.85819294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hadi@cyberus.ca>, <shemminger@linux-foundation.org>,
	<jeff@garzik.org>, <johnpol@2ka.mipt.ru>,
	<herbert@gondor.apana.org.au>, <gaagaan@gmail.com>,
	<Robert.Olsson@data.slu.se>, <netdev@vger.kernel.org>,
	<rdreier@cisco.com>, <mcarlson@broadcom.com>, <jagana@us.ibm.com>,
	<general@lists.openfabrics.org>, <mchan@broadcom.com>,
	<tgraf@suug.ch>, <randy.dunlap@oracle.com>, <sri@us.ibm.com>,
	<kaber@trash.net>
To: "David Miller" <davem@davemloft.net>, <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2985 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754469AbXJJPfh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 11:35:37 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20071010.034446.85819294.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Andi Kleen <andi@firstfloor.org>
> Date: Wed, 10 Oct 2007 12:23:31 +0200
> 
> > On Wed, Oct 10, 2007 at 02:25:50AM -0700, David Miller wrote:
> > > The chip I was working with at the time (UltraSPARC-IIi) 
> compressed 
> > > all the linear stores into 64-byte full cacheline 
> transactions via 
> > > the store buffer.
> > 
> > That's a pretty old CPU. Conclusions on more modern ones 
> might be different.
> 
> Cache matters, just scale the numbers.
> 
> > I suppose it would be an interesting experiment at least.
> 
> Absolutely.
> 
> I've always gotten very poor results when increasing the TX 
> queue a lot, for example with NIU the point of diminishing 
> returns seems to be in the range of 256-512 TX descriptor 
> entries and this was with 1.6Ghz cpus.

We've done similar testing with ixgbe to push maximum descriptor counts,
and we lost performance very quickly in the same range you're quoting on
NIU.

Cheers,
-PJ Waskiewicz
