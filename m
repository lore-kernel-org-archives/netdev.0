From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH v2 net-next 0/8] Introduce bpf ID
Date: Fri, 2 Jun 2017 18:08:13 -0700
Message-ID: <20170603010813.a3zf3etebhlznszq@kafai-mba.local>
References: <cover.1496256722.git.kafai@fb.com>
 <20170531.193518.1564008102407413329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <ast@fb.com>, <daniel@iogearbox.net>,
        <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46364 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751061AbdFCBIr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 21:08:47 -0400
Content-Disposition: inline
In-Reply-To: <20170531.193518.1564008102407413329.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 07:35:18PM -0400, David Miller wrote:
> From: Martin KaFai Lau <kafai@fb.com>
> Date: Wed, 31 May 2017 11:58:54 -0700
>
> > This patch series:
> > 1) Introduce ID for both bpf_prog and bpf_map.
> > 2) Add bpf commands to iterate the prog IDs and map
> >    IDs of the system.
> > 3) Add bpf commands to get a prog/map fd from an ID
> > 4) Add bpf command to get prog/map info from a fd.
> >    The prog/map info is a jump start in this patchset
> >    and it is not meant to be a complete list.  They can
> >    be extended in the future patches.
> >
> > v2:
> > Compiler warning fixes:
> > - Remove lockdep_is_held() usage.  Add comment
> >   to explain the lock situation instead.
> > - Add static for idr related variables
> > - Add __user to the uattr param in bpf_prog_get_info_by_fd()
> >   and bpf_map_get_info_by_fd().
>
> Series applied, thanks Martin.
Patch 1 may not apply cleanly due to another newly added
field in 'struct bpf_prog_aux' on May 31.

Should I respin?
