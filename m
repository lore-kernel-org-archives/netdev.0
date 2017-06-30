From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v5 04/16] bpf: Sample bpf program to set SYN/SYN-ACK
 RTOs
Date: Sat, 01 Jul 2017 01:34:34 +0200
Message-ID: <5956E00A.50705@iogearbox.net>
References: <20170630200706.4183158-1-brakmo@fb.com> <20170630200706.4183158-5-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57415 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751680AbdF3Xem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 19:34:42 -0400
In-Reply-To: <20170630200706.4183158-5-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2017 10:06 PM, Lawrence Brakmo wrote:
> The sample BPF program, tcp_synrto_kern.c, sets the SYN and SYN-ACK
> RTOs to 10ms when both hosts are within the same datacenter (i.e.
> small RTTs) in an environment where common IPv6 prefixes indicate
> both hosts are in the same data center.
>
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
