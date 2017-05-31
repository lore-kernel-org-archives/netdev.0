From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 0/8] Introduce bpf ID
Date: Tue, 30 May 2017 21:30:29 -0700
Message-ID: <20170531042937.jz4swtnaw33dwvbi@kafai-mba.local>
References: <cover.1496189155.git.kafai@fb.com>
 <19cd3d0a-12eb-b8ca-a054-62d86ba2a509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:53202 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750930AbdEaEax (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 00:30:53 -0400
Content-Disposition: inline
In-Reply-To: <19cd3d0a-12eb-b8ca-a054-62d86ba2a509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 30, 2017 at 06:35:37PM -0600, David Ahern wrote:
> On 5/30/17 6:08 PM, Martin KaFai Lau wrote:
> > This patch series:
> > 1) Introduce ID for both bpf_prog and bpf_map.
> > 2) Add bpf commands to iterate the prog IDs and map
> >    IDs of the system.
> > 3) Add bpf commands to get a prog/map fd from an ID
> > 4) Add bpf command to get prog/map info from a fd.
> >    The prog/map info is a jump start in this patchset
> >    and it is not meant to be a complete list.  They can
> >    be extended in the future patches.
>
> Interesting. This really simplifies the bpf retrieval I have been
> working on:
>     https://github.com/dsahern/linux/commits/bpf/retrieve-bpf-wip
>
> Having the net device, filter, route, socket, cgroup, etc return the ids
> for attached programs solves the problem of getting a reference to all
> of the places BPF programs can be placed.
Right, it is the idea.

I am also baking some follow-up patches for returning xdp-prog's id
through netlink.

>
> This patch set turns an id into a fd, and my patches allow the fd to be
> used to get the bpf code.
