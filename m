From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master] bpf: test for valid type in
 bpf_get_work_dir
Date: Wed, 8 Mar 2017 17:57:47 -0800
Message-ID: <20170308175747.2d235bd5@xeon-e3>
References: <31298439f86c34288a26fd4c3d2bcac262d37565.1488801657.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, janerik@rediger.net,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33441 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753969AbdCICGn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 21:06:43 -0500
Received: by mail-pf0-f177.google.com with SMTP id w189so22179690pfb.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 18:06:32 -0800 (PST)
In-Reply-To: <31298439f86c34288a26fd4c3d2bcac262d37565.1488801657.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  6 Mar 2017 13:06:00 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Jan-Erik reported an assertion in bpf_prog_to_subdir() failed where
> type was BPF_PROG_TYPE_UNSPEC, which is only used in bpf_init_env()
> to auto-mount and cache the bpf fs mount point.
> 
> Therefore, make sure when bpf_init_env() is called multiple times
> (f.e. eBPF classifier with eBPF action attached) and bpf_mnt_cached
> is set already that the type is also valid. In bpf_init_env(), we're
> only interested in the mount point and not a type-specific subdir.
> 
> Fixes: e42256699cac ("bpf: make tc's bpf loader generic and move into lib")
> Reported-by: Jan-Erik Rediger <janerik@rediger.net>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied
