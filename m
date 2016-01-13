From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 21:45:07 -0500 (EST)
Message-ID: <20160112.214507.1913407550158910781.davem@davemloft.net>
References: <20160112234707.GA36167@ast-mbp.thefacebook.com>
	<1452651098.1223.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160113022415.GA37041@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, daniel@iogearbox.net, rabin@rab.in,
	netdev@vger.kernel.org, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbcAMCpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 21:45:10 -0500
In-Reply-To: <20160113022415.GA37041@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 12 Jan 2016 18:24:16 -0800

> If anyone wants to submit a patch that masks K &= 31, I would ok
> with it as well, but imo it's a disservice to classic bpf users.

This is how I feel as well.  I hate when some developer of a tool
thinks it's ok to silently let me do something which it can strictly
determine is questionable without my explicitly asking it to do so.
