From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: make bpf_xdp_adjust_head support
 mandatory
Date: Mon, 24 Apr 2017 16:18:45 -0400 (EDT)
Message-ID: <20170424.161845.1467050507287280432.davem@davemloft.net>
References: <6e25ef44c5de02d1feb8b4cc8a2cf60adb4a596e.1493064530.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57288 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968086AbdDXUSv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 16:18:51 -0400
In-Reply-To: <6e25ef44c5de02d1feb8b4cc8a2cf60adb4a596e.1493064530.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 24 Apr 2017 22:14:35 +0200

> Now that also the last in-tree user of the xdp_adjust_head bit has
> been removed, we can remove the flag from struct bpf_prog altogether.
> 
> This, at the same time, also makes sure that any future driver for
> XDP comes with bpf_xdp_adjust_head() support right away.
> 
> A rejection based on this flag would also mean that tail calls
> couldn't be used with such driver as per c2002f983767 ("bpf: fix
> checking xdp_adjust_head on tail calls") fix, thus lets not allow
> for it in the first place.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks Daniel.
