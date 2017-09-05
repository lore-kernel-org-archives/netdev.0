From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master 2/2] bpf: consolidate dumps to use
 bpf_dump_prog_info
Date: Tue, 5 Sep 2017 09:35:01 -0700
Message-ID: <20170905093501.2f1fbbfc@xeon-e3>
References: <cover.1504570627.git.daniel@iogearbox.net>
        <1e96ef342a4f34ee8c8119ee8cc1ed7092ea5ced.1504570627.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:38650 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751774AbdIEQfJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 12:35:09 -0400
Received: by mail-pg0-f47.google.com with SMTP id v66so10267586pgb.5
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 09:35:09 -0700 (PDT)
In-Reply-To: <1e96ef342a4f34ee8c8119ee8cc1ed7092ea5ced.1504570627.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  5 Sep 2017 02:24:32 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Consolidate dump of prog info to use bpf_dump_prog_info() when possible.
> Moving forward, we want to have a consistent output for BPF progs when
> being dumped. E.g. in cls/act case we used to dump tag as a separate
> netlink attribute before we had BPF_OBJ_GET_INFO_BY_FD bpf(2) command.
> 
> Move dumping tag into bpf_dump_prog_info() as well, and only dump the
> netlink attribute for older kernels. Also, reuse bpf_dump_prog_info()
> for XDP case, so we can dump tag and whether program was jited, which
> we currently don't show.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

I applied this to master, and resolved conflicts with net-next.
But the dump with JSON of xdp is now incomplete.
