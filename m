From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after
 some time
Date: Sun, 04 Jan 2009 15:56:13 -0800 (PST)
Message-ID: <20090104.155613.117748633.davem@davemloft.net>
References: <20081229.235230.53178944.davem@davemloft.net>
	<1fd9f5a40812311153y38adff46gd1121d4a510585e1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: berni@birkenwald.de, dlstevens@us.ibm.com, pekkas@netcore.fi,
	netdev@vger.kernel.org
To: eguzovsky@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40372
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751867AbZADX4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 18:56:09 -0500
In-Reply-To: <1fd9f5a40812311153y38adff46gd1121d4a510585e1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eduard Guzovsky" <eguzovsky@gmail.com>
Date: Wed, 31 Dec 2008 14:53:04 -0500

> Thank you for the patch. I tested a slightly modified version of it
> (could not test it "verbatim" - we use a 2.6.18 based kernel) - it
> works!

Thanks for testing.

> Question: I noticed that with your patch ndisc_dst_alloc() can still
> return a dst_entry with NULL as a neighbour. Is this Ok?

There is no ndisc_dst_alloc() in the current tree, that whole
area got redesigned and rearranged since the tree you are using.
