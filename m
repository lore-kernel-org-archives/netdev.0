From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next 2/4] mlx4: xdp: Allow raising MTU up to one page
 minus eth and vlan hdrs
Date: Fri, 2 Dec 2016 16:07:09 -0800
Message-ID: <ba7950ad-d469-5e98-6ed1-ded9f58dba6b@hpe.com>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
 <1480721013-1047541-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hpe.com ([15.241.140.78]:25788 "EHLO
        g4t3425.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753440AbcLCAHL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 19:07:11 -0500
In-Reply-To: <1480721013-1047541-3-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/2016 03:23 PM, Martin KaFai Lau wrote:
> When XDP prog is attached, it is currently limiting
> MTU to be FRAG_SZ0 - ETH_HLEN - (2 * VLAN_HLEN) which is 1514
> in x86.
>
> AFAICT, since mlx4 is doing one page per packet for XDP,
> we can at least raise the MTU limitation up to
> PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN) which this patch is
> doing.  It will be useful in the next patch which allows
> XDP program to extend the packet by adding new header(s).

Is mlx4 the only driver doing page-per-packet?

rick jones
