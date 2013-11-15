From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Do not include padding in TCP GRO checksum
Date: Thu, 14 Nov 2013 23:08:21 -0500 (EST)
Message-ID: <20131114.230821.139211038449295349.davem@davemloft.net>
References: <20131115011413.7090.9349.stgit@ahduyck-fpga.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	herbert@gondor.apana.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755084Ab3KOEI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 23:08:26 -0500
In-Reply-To: <20131115011413.7090.9349.stgit@ahduyck-fpga.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 14 Nov 2013 17:18:18 -0800

> I haven't had a chance to test this much yet and I am not that familiar

As Eric mentioned, unless you tested on big endian, chances are you
didn't test this at all. :-)

You're accessing the IPv4/IPv6 length fields without converting it
to CPU endian.
