From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V1] samples/bpf: bpf_load.c detect and abort
 if ELF maps section size is wrong
Date: Sun, 30 Apr 2017 22:43:06 -0400 (EDT)
Message-ID: <20170430.224306.1606724319950001833.davem@davemloft.net>
References: <20170428082816.20a34395@redhat.com>
        <149338948065.27354.8568861008673180957.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, netdev@vger.kernel.org, eric@regit.org,
        borkmann@iogearbox.net, alexei.starovoitov@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54546 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425674AbdEACnI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:43:08 -0400
In-Reply-To: <149338948065.27354.8568861008673180957.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 28 Apr 2017 16:25:04 +0200

> The struct bpf_map_def was extended in commit fb30d4b71214 ("bpf: Add tests
> for map-in-map") with member unsigned int inner_map_idx.  This changed the size
> of the maps section in the generated ELF _kern.o files.
> 
> Unfortunately the loader in bpf_load.c does not detect or handle this.  Thus,
> older _kern.o files became incompatible, and caused hard-to-debug errors
> where the syscall validation rejected BPF_MAP_CREATE request.
> 
> This patch only detect the situation and aborts load_bpf_file(). It also
> add code comments warning people that read this loader for inspiration
> for these pitfalls.
> 
> Fixes: fb30d4b71214 ("bpf: Add tests for map-in-map")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied.
