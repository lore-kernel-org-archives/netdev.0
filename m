From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net v2] mlx4: Return EOPNOTSUPP instead of ENOTSUPP
Date: Tue, 10 Jan 2017 14:36:45 -0800
Message-ID: <20170110212945.GA83130@kafai-mba.local>
References: <1484070109-105991-1-git-send-email-kafai@fb.com>
 <CALzJLG99semMYGKMO1QvNg1EK0m-uFWv4+-o45oV9t3QoY6_rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:43116 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755565AbdAJWg5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 17:36:57 -0500
Content-Disposition: inline
In-Reply-To: <CALzJLG99semMYGKMO1QvNg1EK0m-uFWv4+-o45oV9t3QoY6_rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 10:04:55PM +0200, Saeed Mahameed wrote:
> On Tue, Jan 10, 2017 at 7:41 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> > In commit b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs"),
> > it changed EOPNOTSUPP to ENOTSUPP by mistake.  This patch fixes it.
> >
> > Fixes: b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs")
> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
>
> Acked-by: Saeed Mahameed <saeedm@mellanox.com>
>
>
> Thank you martin.
>
> Small question though,
> is it essential for the upper layer to get the correct errno ? or this
> is just a cleanup ?
Former.  probably for the netlink's NLMSG_ERROR also.
