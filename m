From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH v2 net-next 0/8] Introduce bpf ID
Date: Wed, 31 May 2017 19:22:56 -0700
Message-ID: <20170531192256.0e0d0ce1@cakuba.lan>
References: <cover.1496256722.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:27806 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751033AbdFACXE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 22:23:04 -0400
In-Reply-To: <cover.1496256722.git.kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 May 2017 11:58:54 -0700, Martin KaFai Lau wrote:
> This patch series:
> 1) Introduce ID for both bpf_prog and bpf_map.
> 2) Add bpf commands to iterate the prog IDs and map
>    IDs of the system.
> 3) Add bpf commands to get a prog/map fd from an ID
> 4) Add bpf command to get prog/map info from a fd.
>    The prog/map info is a jump start in this patchset
>    and it is not meant to be a complete list.  They can
>    be extended in the future patches.

Hi!  IIUC there were plans at some point to store the BPF byte code in
the kernel, the way it was loaded from the user space and before it
went through the verifier.  Are you still planning on implementing that?
It would be handy for offloads to have the original byte code, things
like call inlining make translations of maps calls a bit challenging,
since we try to run through the verifier again..
