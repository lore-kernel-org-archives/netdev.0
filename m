From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch] caif: fix a signedness bug in cfpkt_iterate()
Date: Thu, 19 Feb 2015 10:06:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAE5F02@AcuExch.aculab.com>
References: <20150219091313.GA29358@mwanda>
 <063D6719AE5E284EB5DD2968C1650D6D1CAE5EE1@AcuExch.aculab.com>
 <20150219095944.GD25513@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: 'Dan Carpenter' <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:56885 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453AbbBSKGo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 05:06:44 -0500
In-Reply-To: <20150219095944.GD25513@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter 
> On Thu, Feb 19, 2015 at 09:49:00AM +0000, David Laight wrote:
> > From:  Dan Carpenter
> > ...
> > > Also this isn't ever going to be inlined so I removed the "inline".
> > ...
> > > -inline u16 cfpkt_iterate(struct cfpkt *pkt,
> > > -			 u16 (*iter_func)(u16, void *, u16),
> > > -			 u16 data)
> >
> > static ??
> 
> There are some words missing in this sentence.

I should have drunk some coffee first.

	David
