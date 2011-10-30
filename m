From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2] tcp: Export TCP Delayed ACK parameters to user
Date: Sun, 30 Oct 2011 00:13:49 -0400 (EDT)
Message-ID: <20111030.001349.204270613645747531.davem@davemloft.net>
References: <4EAB2F58.7080509@hp.com>
	<20111028.222430.1568567893138453593.davem@davemloft.net>
	<CAEnQRZCggUnoVZXyXfZ6-Om+hwQL_6Oo3dPODsXAH+iJYqN=jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, luto@amacapital.net
To: dbaluta@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707Ab1J3EQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2011 00:16:56 -0400
In-Reply-To: <CAEnQRZCggUnoVZXyXfZ6-Om+hwQL_6Oo3dPODsXAH+iJYqN=jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Baluta <dbaluta@ixiacom.com>
Date: Sat, 29 Oct 2011 15:32:25 +0300

> * count number of bytes instead of number of segments.

The standard way Linux TCP analyzes connection state based upon
packets, not bytes.

I don't see any value for changing something so fundamental just
for the sake of avoiding the multiply in an obscure facility.

I asked you to make an incision less invasive, yet you're proposal
here more invasive.
