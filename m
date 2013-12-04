From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Wed, 04 Dec 2013 09:40:42 -0800
Message-ID: <1386178842.30495.111.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
	 <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131204.013933.873780415547689253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: or.gerlitz@gmail.com, joseph.gasparakis@intel.com,
	hkchu@google.com, ogerlitz@mellanox.com, edumazet@google.com,
	ast@plumgrid.com, pshelar@nicira.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:35757 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981Ab3LDRkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 12:40:47 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so23931514pbb.18
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 09:40:47 -0800 (PST)
In-Reply-To: <20131204.013933.873780415547689253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-04 at 01:39 -0500, David Miller wrote:

> I definitely prefer the control block approach to this.

I polished the patch to keep this knowledge in net/core/dev.c
