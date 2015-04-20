From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH iproute2 -next] examples: bpf: fix ld offs to have same
 prog loaded on ingress/egress
Date: Mon, 20 Apr 2015 14:17:33 -0700
Message-ID: <55356CED.2050200@plumgrid.com>
References: <02fed6731d00ae1af3936c58e363a4e2d1df13e5.1429528359.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33981 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544AbbDTVRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 17:17:35 -0400
Received: by pdbqa5 with SMTP id qa5so219317258pdb.1
        for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 14:17:35 -0700 (PDT)
In-Reply-To: <02fed6731d00ae1af3936c58e363a4e2d1df13e5.1429528359.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/15 4:48 AM, Daniel Borkmann wrote:
> Fix up the eBPF example program to match our kernel fix in a166151cbe33 ("bpf:
> fix bpf helpers to use skb->mac_header relative offsets"). Tested on ingress
> and egress paths.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> ---
>   ( Stephen, this applies on top of "tc: built-in eBPF exec proxy":
>     https://patchwork.ozlabs.org/patch/461837/ )

Looks good.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
