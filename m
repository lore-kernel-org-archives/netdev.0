From: David Miller <davem@davemloft.net>
Subject: Re: net_test_tools: add ipv6 support for kbench_mod
Date: Wed, 14 Jan 2015 01:35:40 -0500 (EST)
Message-ID: <20150114.013540.1963709251689177055.davem@davemloft.net>
References: <20150114054548.GA2683397@devbig257.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kafai@fb.com
To: shli@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbbANGfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 01:35:45 -0500
In-Reply-To: <20150114054548.GA2683397@devbig257.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohua Li <shli@fb.com>
Date: Tue, 13 Jan 2015 21:45:48 -0800

> This patch adds ipv6 support for kbench_mod test module

This doesn't even link because ip6_route_input is not an
exported symbol.

So you either didn't test this, or it depends upon custom
kernel changes which you didn't mention.

Either way I can't apply this, sorry.
