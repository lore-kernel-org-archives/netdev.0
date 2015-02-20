From: "tgraf@suug.ch" <tgraf@suug.ch>
Subject: Re: [PATCH net 1/3] rhashtable: don't test for shrink on insert,
 expansion on delete
Date: Fri, 20 Feb 2015 11:56:51 +0000
Message-ID: <20150220115651.GA4586@casper.infradead.org>
References: <cover.1424389682.git.daniel@iogearbox.net>
 <55e6cbcc9c4b7a831d72d3e3ec39c024f494f9e2.1424389682.git.daniel@iogearbox.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CAE675F@AcuExch.aculab.com>
 <54E708D2.8030306@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ying Xue <ying.xue@windriver.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51352 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306AbbBTL44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 06:56:56 -0500
Content-Disposition: inline
In-Reply-To: <54E708D2.8030306@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/15 at 11:13am, Daniel Borkmann wrote:
> On 02/20/2015 11:08 AM, David Laight wrote:
> ...
> >Does it actually make sense to shrink below the initial default size?
> 
> rhashtable has a min_shift parameter, shrinks cannot go below that.

Right, it's up to the user to set min_shift according to nelems hint
or not. I see use cases for both behaviours.
