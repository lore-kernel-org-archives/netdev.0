From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 7/7] samples/bpf: xdp_monitor tool based on tracepoints
Date: Tue, 29 Aug 2017 19:24:38 +0200
Message-ID: <59A5A356.108@iogearbox.net>
References: <150401743083.16384.15778781741742858567.stgit@firesoul> <150401749138.16384.17129327124102881342.stgit@firesoul> <20170829170551.5uws25py4fcpem73@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44458 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751283AbdH2RYl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 13:24:41 -0400
In-Reply-To: <20170829170551.5uws25py4fcpem73@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2017 07:05 PM, Alexei Starovoitov wrote:
> On Tue, Aug 29, 2017 at 04:38:11PM +0200, Jesper Dangaard Brouer wrote:
>> This tool xdp_monitor demonstrate how to use the different xdp_redirect
>> tracepoints xdp_redirect{,_map}{,_err} from a BPF program.
>>
>> The default mode is to only monitor the error counters, to avoid
>> affecting the per packet performance. Tracepoints comes with a base
>> overhead of 25 nanosec for an attached bpf_prog, and 48 nanosec for
>> using a full perf record (with non-matching filter).  Thus, default
>> loading the --stats mode could affect the maximum performance.
>>
>> This version of the tool is very simple and count all types of errors
>> as one.  It will be natural to extend this later with the different
>> types of errors that can occur, which should help users quickly
>> identify common mistakes.
>>
>> Because the TP_STRUCT was kept in sync all the tracepoints loads the
>> same BPF code.  It would also be natural to extend the map version to
>> demonstrate how the map information could be used.
>>
>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>
> Nice. Did you consider using libbbpf (instead of old bpf_load.c hack)
> and make full standalone tool out of it? Looks very useful.

+1 also my suggestion. ;)

> Acked-by: Alexei Starovoitov <ast@kernel.org>
