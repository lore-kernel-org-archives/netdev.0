From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] neigh: make struct neigh_table::entry_size
 unsigned int
Date: Mon, 25 Sep 2017 20:36:43 -0700 (PDT)
Message-ID: <20170925.203643.323691746055685663.davem@davemloft.net>
References: <20170923200106.GA24928@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933685AbdIZDgo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 23:36:44 -0400
In-Reply-To: <20170923200106.GA24928@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 23 Sep 2017 23:01:06 +0300

> Neigh entry size can't be negative.
> 
> Space savings:
> 
> 	add/remove: 0/0 grow/shrink: 0/5 up/down: 0/-7 (-7)
> 	function                                     old     new   delta
> 	lowpan_neigh_construct                        25      24      -1
> 	clip_seq_sub_iter                            152     151      -1
> 	clip_ioctl                                  1475    1474      -1
> 	clip_constructor                              93      92      -1
> 	__neigh_create                              2455    2452      -3
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
