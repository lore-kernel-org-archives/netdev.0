From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC 0/2] ila: ilarouter bpf code for tc and xdp
Date: Fri, 23 Sep 2016 20:06:52 +0200
Message-ID: <20160923200652.5a8d5dff@redhat.com>
References: <1474650995-2031928-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tom Herbert <tom@herbertland.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Thomas Graf <tgraf@suug.ch>, <netdev@vger.kernel.org>,
        brouer@redhat.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42502 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964828AbcIWSG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 14:06:57 -0400
In-Reply-To: <1474650995-2031928-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 23 Sep 2016 10:16:33 -0700 Alexei Starovoitov <ast@fb.com> wrote:

> From: Aaron Yue <haoxuany@andrew.cmu.edu>
> 
> Jesper,
> 
> here is old email and cover letter that didn't make it to the list
> due to vger outage (I guess).
> The verifier patch that Aaron is talking about has landed long ago.
> 
> The dataplane of ILA router is very short and simple.

Yes, looks very simple indeed! Cool! :-)


> Control plane is very different matter. It's not ready for prime time yet.
> 
> ----------
> 
> This patch contains the tc and xdp implementation of kernelspace bpf code.
> It requires userspace to insert to the ILA bpf maps, in tc's case, the 
> precomputed ILA mappings, and in xdp's case, both the precomputed ILA
> mappings and the MAC address.
> 
> The xdp bpf code also requires a verifier patch to allow direct map access
> from the packet (will be patched in by Alexei).
> 
> Aaron Yue (2):
>   samples/bpf: ilarouter for tc
>   samples/bpf: ilarouter for xdp
> 
>  samples/bpf/Makefile        |   2 +
>  samples/bpf/ila.h           |  80 ++++++++++++++++++++++++++++
>  samples/bpf/ilarouter_tc.c  | 124 ++++++++++++++++++++++++++++++++++++++++++++
>  samples/bpf/ilarouter_xdp.c |  88 +++++++++++++++++++++++++++++++
>  samples/bpf/inet_helper.h   |  38 ++++++++++++++
>  5 files changed, 332 insertions(+)
>  create mode 100644 samples/bpf/ila.h
>  create mode 100644 samples/bpf/ilarouter_tc.c
>  create mode 100644 samples/bpf/ilarouter_xdp.c
>  create mode 100644 samples/bpf/inet_helper.h

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
