From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.39-rc7-git11, x86/32, failed on ppp2897'th interface,
 PERCPU: allocation failed
Date: Thu, 19 May 2011 03:51:11 -0400 (EDT)
Message-ID: <20110519.035111.674555242805661539.davem@davemloft.net>
References: <f9797bb034f650a24e927629d1ab77d8@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755777Ab1ESHvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 03:51:16 -0400
In-Reply-To: <f9797bb034f650a24e927629d1ab77d8@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Fedoryshchenko <denys@visp.net.lb>
Date: Thu, 19 May 2011 09:35:29 +0300

> I am not sure it is a bug, but it looks i had free memory(the box had
> 8GB free), and lowmem too, also i will try to enable there 64bit
> kernel at evening.

It's not free memory, you ran out of per-cpu chunks which are allocated
in fixed virtual region(s).
