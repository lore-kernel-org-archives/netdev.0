From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] bpf: Remove the capability check for
 cgroup skb eBPF program
Date: Thu, 1 Jun 2017 18:58:17 -0700
Message-ID: <20170602015815.u4lecyfap6l6lenr@ast-mbp>
References: <1496279760-20996-1-git-send-email-chenbofeng.kernel@gmail.com>
 <1496279760-20996-2-git-send-email-chenbofeng.kernel@gmail.com>
 <20170601234235.iwu55crijtxuq5mp@ast-mbp>
 <CAMOXUJkHsj8c6Yc8FSvJsFt3vPcf-UKV0PPVWY8ewcZuA2vUwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>
To: Chenbo Feng <fengc@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34157 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751122AbdFBB6U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 21:58:20 -0400
Received: by mail-pf0-f194.google.com with SMTP id w69so10230162pfk.1
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 18:58:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAMOXUJkHsj8c6Yc8FSvJsFt3vPcf-UKV0PPVWY8ewcZuA2vUwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 01, 2017 at 06:55:09PM -0700, Chenbo Feng wrote:
> On Thu, Jun 1, 2017 at 4:42 PM, Alexei Starovoitov <
> alexei.starovoitov@gmail.com> wrote:
> 
> > On Wed, May 31, 2017 at 06:16:00PM -0700, Chenbo Feng wrote:
> > > From: Chenbo Feng <fengc@google.com>
> > >
> > > Currently loading a cgroup skb eBPF program require a CAP_SYS_ADMIN
> > > capability while attaching the program to a cgroup only requires the
> > > user have CAP_NET_ADMIN privilege. We can escape the capability
> > > check when load the program just like socket filter program to make
> > > the capability requirement consistent.
> > >
> > > Change since v1:
> > > Change the code style in order to be compliant with checkpatch.pl
> > > preference
> > >
> > > Signed-off-by: Chenbo Feng <fengc@google.com>
> >
> > as far as I can see they're indeed the same as socket filters, so
> > Acked-by: Alexei Starovoitov <ast@kernel.org>
> >
> > but I don't quite understand how it helps, since as you said
> > attaching such unpriv fd to cgroup still requires root.
> > Do you have more patches to follow?
> >
> > Actually not, the purpose of this patch is only to make sure if a program
> have
> CAP_NET_ADMIN but not CAP_SYS_ADMIN it can still load and attach eBPF
> programs to cgroup.

got it. Thanks
