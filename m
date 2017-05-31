From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 0/8] Introduce bpf ID
Date: Tue, 30 May 2017 18:35:37 -0600
Message-ID: <19cd3d0a-12eb-b8ca-a054-62d86ba2a509@gmail.com>
References: <cover.1496189155.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34326 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdEaAfk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:35:40 -0400
Received: by mail-pf0-f196.google.com with SMTP id w69so415050pfk.1
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:35:40 -0700 (PDT)
In-Reply-To: <cover.1496189155.git.kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/30/17 6:08 PM, Martin KaFai Lau wrote:
> This patch series:
> 1) Introduce ID for both bpf_prog and bpf_map.
> 2) Add bpf commands to iterate the prog IDs and map
>    IDs of the system.
> 3) Add bpf commands to get a prog/map fd from an ID
> 4) Add bpf command to get prog/map info from a fd.
>    The prog/map info is a jump start in this patchset
>    and it is not meant to be a complete list.  They can
>    be extended in the future patches.

Interesting. This really simplifies the bpf retrieval I have been
working on:
    https://github.com/dsahern/linux/commits/bpf/retrieve-bpf-wip

Having the net device, filter, route, socket, cgroup, etc return the ids
for attached programs solves the problem of getting a reference to all
of the places BPF programs can be placed.

This patch set turns an id into a fd, and my patches allow the fd to be
used to get the bpf code.
