From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] Netpoll support for Sibyte MAC
Date: Tue, 20 Mar 2007 10:22:48 +0900 (JST)
Message-ID: <20070320.102248.68134682.nemoto@toshiba-tops.co.jp>
References: <20070319224311.GA10176@plexity.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, jeff@garzik.org,
	linux-mips@linux-mips.org, mlachwani@mvista.com
To: dsaxena@plexity.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from topsns2.toshiba-tops.co.jp ([202.230.225.126]:29107 "EHLO
	topsns2.toshiba-tops.co.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965693AbXCTBWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 21:22:55 -0400
In-Reply-To: <20070319224311.GA10176@plexity.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Mar 2007 15:43:11 -0700, Deepak Saxena <dsaxena@plexity.net> wrote:
> NETPOLL support for Sibyte MAC
> 
> Signed-off-by: Manish Lachwani <mlachwani@mvista.com>
> Signed-off-by: Deepak Saxena <dsaxena@mvista.com>

If you added NETPOLL support, do not forget to ensure hard_start_xmit
routine callable from interrupt context (or irq disabled).
See commit bce305f4fe779f29d99d414685243f5da0803254 for example.

---
Atsushi Nemoto
