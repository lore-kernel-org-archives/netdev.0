From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix exthdrs offload registration in out_rt
 path
Date: Wed, 02 Sep 2015 15:31:26 -0700 (PDT)
Message-ID: <20150902.153126.1471519064187559522.davem@davemloft.net>
References: <fcd965e793be00159b46bbc672dd742e2f2615aa.1441230755.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbbIBWb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 18:31:29 -0400
In-Reply-To: <fcd965e793be00159b46bbc672dd742e2f2615aa.1441230755.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu,  3 Sep 2015 00:29:07 +0200

> We previously register IPPROTO_ROUTING offload under inet6_add_offload(),
> but in error path, we try to unregister it with inet_del_offload(). This
> doesn't seem correct, it should actually be inet6_del_offload(), also
> ipv6_exthdrs_offload_exit() from that commit seems rather incorrect (it
> also uses rthdr_offload twice), but it got removed entirely later on.
> 
> Fixes: 3336288a9fea ("ipv6: Switch to using new offload infrastructure.")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks Daniel.
