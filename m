From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Mon, 15 Jul 2013 16:34:08 +0200
Message-ID: <20130715163408.4064699f@skate>
References: <20130704173552.GA23370@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Eric Dumazet <edumazet@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:57434 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466Ab3GOOeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 10:34:11 -0400
In-Reply-To: <20130704173552.GA23370@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Willy Tarreau,

On Thu, 4 Jul 2013 19:35:52 +0200, Willy Tarreau wrote:
> From 0180a5e651dd771de18bf2c031ecfe7bb4c88d3e Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Sat, 15 Jun 2013 23:25:15 +0200
> Subject: [PATCH] net: convert mvneta to build_skb()
> 
> We store the frag_size in the mvneta_port struct. In practice we'd need
> a single bit to know how to free the data, but since we need the size to
> call build_skb() anyway, let's store the full size.
> 
> With this patch, I observed a reproducible 2% performance improvement on
> HTTP-based benchmarks.
> 
> Signed-off-by: Willy Tarreau <w@1wt.eu>

3.11-rc1 is now out. Do you intend to resend an updated version of your
patches, according to the discussions we had?

Thanks!

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
