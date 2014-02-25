From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] ipv4: allow IP_PMTUDISC_INTERFACE generate
 fragments if packet size is larger than interface mtu
Date: Mon, 24 Feb 2014 20:28:40 -0500 (EST)
Message-ID: <20140224.202840.1970998149311770621.davem@davemloft.net>
References: <20140225005814.GA12189@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fweimer@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbaBYB2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 20:28:41 -0500
In-Reply-To: <20140225005814.GA12189@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 25 Feb 2014 01:58:14 +0100

> I hope changing this socket option slightly to be more permissive while
> already being in a released kernel is acceptable.

There is no way to detect the change in semantics, and logically
therefore no way to safely use it.
