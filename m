From: David Miller <davem@davemloft.net>
Subject: Re: net: alignment problem in icmp code
Date: Mon, 22 Oct 2007 02:05:38 -0700 (PDT)
Message-ID: <20071022.020538.74751031.davem@davemloft.net>
References: <20071022092350.5c75b3bd@poseidon.drzeus.cx>
	<20071022.013105.74746322.davem@davemloft.net>
	<20071022104208.78c79467@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: drzeus@drzeus.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750807AbXJVJFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 05:05:17 -0400
In-Reply-To: <20071022104208.78c79467@poseidon.drzeus.cx>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pierre Ossman <drzeus@drzeus.cx>
Date: Mon, 22 Oct 2007 10:42:08 +0200

> This seems like a rather evil layering violation.

This has a 10+ year precedence and it's why the Linux networking stack
is so fast.  If you read any other driver you would have seen the
skb_reserve() call every one of them do to align the headers.

I think I've tolerated this long enough.

Are you going keep teaching me how the C language works, how GCC
interprets it, and how evil the Linux networking is, or are you going
to fix the bug in your driver? :-)
