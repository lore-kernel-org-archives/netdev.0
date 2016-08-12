From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next v4 2/3] bpf: Add bpf_current_task_under_cgroup
 helper
Date: Fri, 12 Aug 2016 11:28:41 -0400
Message-ID: <20160812152841.GP2695@mtj.duckdns.org>
References: <20160812031454.GA2075@ircssh.c.rugged-nimbus-611.internal>
 <20160812044818.GA39190@ast-mbp.thefacebook.com>
 <CAMp4zn-0ox8DLO0jNP9Z2+RKqbHmcrRS_dr+L0de_bd=17mp_w@mail.gmail.com>
 <57AD77B7.5050400@iogearbox.net>
 <20160812072247.GB31242@ircssh.c.rugged-nimbus-611.internal>
 <57AD7D77.4090205@iogearbox.net>
 <20160812132935.GL2695@mtj.duckdns.org>
 <20160812152120.GA41700@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Sargun Dhillon <sargun@sargun.me>,
	netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35556 "EHLO
	mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbcHLP3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 11:29:42 -0400
Received: by mail-qt0-f195.google.com with SMTP id q11so1086058qtb.2
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 08:28:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160812152120.GA41700@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Alexei.

On Fri, Aug 12, 2016 at 08:21:21AM -0700, Alexei Starovoitov wrote:
> > lol I should have read the whole thread before replying twice.  Sorry
> > about that.  Yeah, if we can still rename it, let's do "under".  It's
> > more intuitive and gives us the room to implement the real "in" test
> > if ever necessary in the future.
> 
> agree. Thanks for explaining 'in' vs 'under' terminology.
> since we can still rename skb_in_cgroup we should do it.

Sounds good to me.

> and since that was my only nit for this patch.
> Acked-by: Alexei Starovoitov <ast@kernel.org>

FWIW,

Acked-by: Tejun Heo <tj@kernel.org>

> All 3 patches should go via net-next and to avoid conflicts 1/3 can be
> in cgroup tree as well (if you think there will be conflicts).
> We did that in the past with tip and net-next and it worked out well.

Yeah, just route it through net-next.  If other changes ever need it,
I'll include the commit in cgroup tree.

Thanks.

-- 
tejun
