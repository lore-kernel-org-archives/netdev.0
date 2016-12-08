From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH v4 net-next 1/4] bpf: xdp: Allow head adjustment in XDP
 prog
Date: Thu, 8 Dec 2016 09:00:44 -0800
Message-ID: <584991BC.80102@gmail.com>
References: <1481154794-2311034-1-git-send-email-kafai@fb.com>
 <1481154794-2311034-2-git-send-email-kafai@fb.com>
 <584921AD.3060004@iogearbox.net>
 <20161208165515.GA92599@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35581 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752511AbcLHRBD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 12:01:03 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so27367581pga.2
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 09:01:02 -0800 (PST)
In-Reply-To: <20161208165515.GA92599@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-08 08:55 AM, Alexei Starovoitov wrote:
> On Thu, Dec 08, 2016 at 10:02:37AM +0100, Daniel Borkmann wrote:
>> On 12/08/2016 12:53 AM, Martin KaFai Lau wrote:
>>> This patch allows XDP prog to extend/remove the packet
>>> data at the head (like adding or removing header).  It is
>>> done by adding a new XDP helper bpf_xdp_adjust_head().
>>>
>>> It also renames bpf_helper_changes_skb_data() to
>>> bpf_helper_changes_pkt_data() to better reflect
>>> that XDP prog does not work on skb.
>>>
>>> This patch adds one "xdp_adjust_head" bit to bpf_prog for the
>>> XDP-capable driver to check if the XDP prog requires
>>> bpf_xdp_adjust_head() support.  The driver can then decide
>>> to error out during XDP_SETUP_PROG.
>>>
>>> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
>>
>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> 
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> 

Thanks for fixing up the xdp_buff struct. And for good measure,

Acked-by: John Fastabend <john.r.fastabend@intel.com>
