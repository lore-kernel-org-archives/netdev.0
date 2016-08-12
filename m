From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next v4 2/3] bpf: Add bpf_current_task_under_cgroup
 helper
Date: Fri, 12 Aug 2016 09:21:39 -0400
Message-ID: <20160812132139.GI2695@mtj.duckdns.org>
References: <20160812031454.GA2075@ircssh.c.rugged-nimbus-611.internal>
 <20160812044818.GA39190@ast-mbp.thefacebook.com>
 <CAMp4zn-0ox8DLO0jNP9Z2+RKqbHmcrRS_dr+L0de_bd=17mp_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36023 "EHLO
	mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbcHLNVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 09:21:43 -0400
Received: by mail-qt0-f193.google.com with SMTP id u25so964606qtb.3
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 06:21:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAMp4zn-0ox8DLO0jNP9Z2+RKqbHmcrRS_dr+L0de_bd=17mp_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 11, 2016 at 09:50:48PM -0700, Sargun Dhillon wrote:
> I realize that in_cgroup is more consistent, but under_cgroup makes
> far more sense to me. I think it's more intuitive.

So, I think in_cgroup should mean that the object is in that
particular cgroup while under_cgroup in the subhierarchy of that
cgroup.  Let's rename the other subhierarchy test to under too.  I
think that'd be a lot less confusing going forward.

Thanks.

-- 
tejun
