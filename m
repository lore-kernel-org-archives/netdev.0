From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/4] Improve bpf ELF-loader under samples/bpf
Date: Wed, 03 May 2017 09:30:53 -0400 (EDT)
Message-ID: <20170503.093053.566117076075958592.davem@davemloft.net>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, netdev@vger.kernel.org, eric@regit.org,
        borkmann@iogearbox.net, alexei.starovoitov@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36738 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752493AbdECNaz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 09:30:55 -0400
In-Reply-To: <149372826543.22268.3617359219409721129.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 02 May 2017 14:31:45 +0200

> This series improves and fixes bpf ELF loader and programs under
> samples/bpf.  The bpf_load.c created some hard to debug issues when
> the struct (bpf_map_def) used in the ELF maps section format changed
> in commit fb30d4b71214 ("bpf: Add tests for map-in-map").
> 
> This was hotfixed in commit 409526bea3c3 ("samples/bpf: bpf_load.c
> detect and abort if ELF maps section size is wrong") by detecting the
> issue and aborting the program.
> 
> In most situations the bpf-loader should be able to handle these kind
> of changes to the struct size.  This patch series aim to do proper
> backward and forward compabilility handling when loading ELF files.
> 
> This series also adjust the callback that was introduced in commit
> 9fd63d05f3e8 ("bpf: Allow bpf sample programs (*_user.c) to change
> bpf_map_def") to use the new bpf_map_data structure, before more users
> start to use this callback.
> 
> Hoping these changes can make the merge window, as above mentioned
> commits have not been merged yet, and it would be good to avoid users
> hitting these issues.

I've applied this series, thanks!
