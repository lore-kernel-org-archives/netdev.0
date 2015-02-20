From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 1/3] rhashtable: don't test for shrink on insert,
 expansion on delete
Date: Fri, 20 Feb 2015 10:08:26 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAE675F@AcuExch.aculab.com>
References: <cover.1424389682.git.daniel@iogearbox.net>
 <55e6cbcc9c4b7a831d72d3e3ec39c024f494f9e2.1424389682.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ying Xue <ying.xue@windriver.com>
To: 'Daniel Borkmann' <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:50835 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934AbbBTKJI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 05:09:08 -0500
In-Reply-To: <55e6cbcc9c4b7a831d72d3e3ec39c024f494f9e2.1424389682.git.daniel@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann
> Restore pre 54c5b7d311c8 behaviour and only probe for expansions on inserts
> and shrinks on deletes. Currently, it will happen that on initial inserts
> into a sparse hash table, we may i.e. shrink it first simply because it's
> not fully populated yet, only to later realize that we need to grow again.
> 
> This however is counter intuitive, e.g. an initial default size of 64
> elements is already small enough, and in case an elements size hint is given
> to the hash table by a user, we should avoid unnecessary expansion steps,
> so a shrink is clearly unintended here.

Does it actually make sense to shrink below the initial default size?

	David
