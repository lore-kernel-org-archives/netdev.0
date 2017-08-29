From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 7/7] samples/bpf: xdp_monitor tool based on
 tracepoints
Date: Tue, 29 Aug 2017 10:05:52 -0700
Message-ID: <20170829170551.5uws25py4fcpem73@ast-mbp>
References: <150401743083.16384.15778781741742858567.stgit@firesoul>
 <150401749138.16384.17129327124102881342.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35874 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbdH2RFz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 13:05:55 -0400
Received: by mail-pg0-f49.google.com with SMTP id r133so12478647pgr.3
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 10:05:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150401749138.16384.17129327124102881342.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 04:38:11PM +0200, Jesper Dangaard Brouer wrote:
> This tool xdp_monitor demonstrate how to use the different xdp_redirect
> tracepoints xdp_redirect{,_map}{,_err} from a BPF program.
> 
> The default mode is to only monitor the error counters, to avoid
> affecting the per packet performance. Tracepoints comes with a base
> overhead of 25 nanosec for an attached bpf_prog, and 48 nanosec for
> using a full perf record (with non-matching filter).  Thus, default
> loading the --stats mode could affect the maximum performance.
> 
> This version of the tool is very simple and count all types of errors
> as one.  It will be natural to extend this later with the different
> types of errors that can occur, which should help users quickly
> identify common mistakes.
> 
> Because the TP_STRUCT was kept in sync all the tracepoints loads the
> same BPF code.  It would also be natural to extend the map version to
> demonstrate how the map information could be used.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Nice. Did you consider using libbbpf (instead of old bpf_load.c hack)
and make full standalone tool out of it? Looks very useful.
Acked-by: Alexei Starovoitov <ast@kernel.org>
