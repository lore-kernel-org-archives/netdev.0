From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v4 2/3] bpf: Add bpf_current_task_under_cgroup
 helper
Date: Fri, 12 Aug 2016 08:21:21 -0700
Message-ID: <20160812152120.GA41700@ast-mbp.thefacebook.com>
References: <20160812031454.GA2075@ircssh.c.rugged-nimbus-611.internal>
 <20160812044818.GA39190@ast-mbp.thefacebook.com>
 <CAMp4zn-0ox8DLO0jNP9Z2+RKqbHmcrRS_dr+L0de_bd=17mp_w@mail.gmail.com>
 <57AD77B7.5050400@iogearbox.net>
 <20160812072247.GB31242@ircssh.c.rugged-nimbus-611.internal>
 <57AD7D77.4090205@iogearbox.net>
 <20160812132935.GL2695@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Sargun Dhillon <sargun@sargun.me>,
	netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34349 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbcHLPV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 11:21:26 -0400
Received: by mail-pa0-f67.google.com with SMTP id hh10so1636045pac.1
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 08:21:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160812132935.GL2695@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 09:29:35AM -0400, Tejun Heo wrote:
> Hello,
> 
> On Fri, Aug 12, 2016 at 09:40:39AM +0200, Daniel Borkmann wrote:
> > > I actually wish we could rename skb_in_cgroup to skb_under_cgroup. If we ever
> > > introduced a check for absolute membership versus ancestral membership, what
> > > would we call that?
> > 
> > That option is, by the way, still on the table for -net tree, since 4.8 is not
> > released yet, so it could still be renamed into BPF_FUNC_skb_under_cgroup.
> > 
> > Then you could make this one here for -net-next as "BPF_FUNC_current_under_cgroup".
> > 
> > Tejun, Alexei?
> 
> lol I should have read the whole thread before replying twice.  Sorry
> about that.  Yeah, if we can still rename it, let's do "under".  It's
> more intuitive and gives us the room to implement the real "in" test
> if ever necessary in the future.

agree. Thanks for explaining 'in' vs 'under' terminology.
since we can still rename skb_in_cgroup we should do it.

and since that was my only nit for this patch.
Acked-by: Alexei Starovoitov <ast@kernel.org>

All 3 patches should go via net-next and to avoid conflicts 1/3 can be
in cgroup tree as well (if you think there will be conflicts).
We did that in the past with tip and net-next and it worked out well.
Daniel or Martin, do you mind preparing in->under renaming patch for net?

Thanks!
