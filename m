From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next v4 2/3] bpf: Add bpf_current_task_under_cgroup
 helper
Date: Fri, 12 Aug 2016 09:23:51 -0400
Message-ID: <20160812132351.GJ2695@mtj.duckdns.org>
References: <20160812031454.GA2075@ircssh.c.rugged-nimbus-611.internal>
 <20160812044818.GA39190@ast-mbp.thefacebook.com>
 <CAMp4zn-0ox8DLO0jNP9Z2+RKqbHmcrRS_dr+L0de_bd=17mp_w@mail.gmail.com>
 <20160812132139.GI2695@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34977 "EHLO
	mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbcHLNXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 09:23:53 -0400
Received: by mail-qt0-f194.google.com with SMTP id q11so965126qtb.2
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 06:23:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160812132139.GI2695@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 09:21:39AM -0400, Tejun Heo wrote:
> On Thu, Aug 11, 2016 at 09:50:48PM -0700, Sargun Dhillon wrote:
> > I realize that in_cgroup is more consistent, but under_cgroup makes
> > far more sense to me. I think it's more intuitive.
> 
> So, I think in_cgroup should mean that the object is in that
> particular cgroup while under_cgroup in the subhierarchy of that
> cgroup.  Let's rename the other subhierarchy test to under too.  I
> think that'd be a lot less confusing going forward.

Ah, I suppose the bpf part is userland visible?  If so, there isn't
much we can do and probably best to stick with in_cgroup for that
part.  Bummer but no big deal.

Thanks.

-- 
tejun
