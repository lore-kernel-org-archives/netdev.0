From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2] tcp: Export TCP Delayed ACK parameters to user
Date: Fri, 28 Oct 2011 22:24:30 -0400 (EDT)
Message-ID: <20111028.222430.1568567893138453593.davem@davemloft.net>
References: <CAEnQRZCxSPb8NRceB+tfdZnkN=K-jGbdmXDgNwEhZFYAWGmvAg@mail.gmail.com>
	<20111028.183107.2091450715774357523.davem@davemloft.net>
	<4EAB2F58.7080509@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbaluta@ixiacom.com, eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, luto@amacapital.net
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104Ab1J2C1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 22:27:35 -0400
In-Reply-To: <4EAB2F58.7080509@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 28 Oct 2011 15:40:24 -0700

> That would be loads faster, but won't that have issues with
> granularity?

Frankly, I don't care.

For an obscure feature I don't even like to begin with, I refuse
to allow a multiply into a core code path.
