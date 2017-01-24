From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, lpm: fix kfree of im_node in
 trie_update_elem
Date: Mon, 23 Jan 2017 21:18:06 -0500 (EST)
Message-ID: <20170123.211806.746993274029353312.davem@davemloft.net>
References: <6052894aa1bd4df5a5c7aaa05f5b63a980cbe371.1485217298.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@zonque.org, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43104 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdAXCSK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 21:18:10 -0500
In-Reply-To: <6052894aa1bd4df5a5c7aaa05f5b63a980cbe371.1485217298.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 24 Jan 2017 01:26:46 +0100

> We need to initialize im_node to NULL, otherwise in case of error path
> it gets passed to kfree() as uninitialized pointer.
> 
> Fixes: b95a5c4db09b ("bpf: add a longest prefix match trie map implementation")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  Mentioned it in http://patchwork.ozlabs.org/patch/718070/, but
>  was probably overlooked.

Applied, thanks.
