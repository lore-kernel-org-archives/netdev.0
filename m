From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 21:43:15 -0500 (EST)
Message-ID: <20160112.214315.2135966842775837844.davem@davemloft.net>
References: <1452641302.1223.35.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160112234707.GA36167@ast-mbp.thefacebook.com>
	<1452651098.1223.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net, rabin@rab.in,
	netdev@vger.kernel.org, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbcAMCnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 21:43:18 -0500
In-Reply-To: <1452651098.1223.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 Jan 2016 18:11:38 -0800

> As I said, it is possible some guys never noticed their BPF program
> were 'broken' because this invalid shift was hidden in a dead code
> part.

We should not hide bugs and unintended uses of operations with
undefined behavior.
