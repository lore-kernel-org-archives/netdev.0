From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 03/10] bpf: mlx5e: Report bpf_prog ID during
 XDP_QUERY_PROG
Date: Tue, 13 Jun 2017 11:49:48 -0700
Message-ID: <20170613184948.wx326pyjauju7iti@dhcp-172-26-110-210.dhcp.thefacebook.com>
References: <20170613010025.2983342-1-kafai@fb.com>
 <20170613010025.2983342-4-kafai@fb.com>
 <CALzJLG_mos9=Tw0A0xASi3U3PF+=5-+e+K4ZdsR6M_saZ5B+0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39759 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751826AbdFMSuK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 14:50:10 -0400
Content-Disposition: inline
In-Reply-To: <CALzJLG_mos9=Tw0A0xASi3U3PF+=5-+e+K4ZdsR6M_saZ5B+0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 13, 2017 at 07:04:26PM +0300, Saeed Mahameed wrote:
> On Tue, Jun 13, 2017 at 4:00 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> > Add support to mlx5e to report bpf_prog ID during XDP_QUERY_PROG.
> >
> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> > Cc: Tariq Toukan <tariqt@mellanox.com>
> > Cc: Saeed Mahameed <saeedm@mellanox.com>
> > Acked-by: Alexei Starovoitov <ast@fb.com>
> > Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>
> Acked-by: Saeed Mahameed <saeedm@mellanox.com>
Thanks for reviewing, Saeed.

I will respin v2 with READ_ONCE removed since
it is already under rtnl lock per Jakub Kicinski's
suggestion in nfp.  The situation should be similar
in mlx5e.
