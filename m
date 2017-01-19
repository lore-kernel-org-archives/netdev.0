From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Thu, 19 Jan 2017 10:00:08 +0100
Message-ID: <20170119090006.GI30786@dhcp22.suse.cz>
References: <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <2dbec775-6304-e44c-19c5-fbf07877e7b1@gmail.com>
 <CALCETrUW2jEYmjSsOrPj+MAjkDGGUCw_rdxQh+5Er0r4ReGLnA@mail.gmail.com>
 <20161220091150.GJ3124@twins.programming.kicks-ass.net>
 <20170103102559.GA30129@dhcp22.suse.cz>
 <20170116011901.GH14446@mtj.duckdns.org>
 <20170117130303.GL19699@dhcp22.suse.cz>
 <20170117133204.GA6515@twins.programming.kicks-ass.net>
 <20170117135830.GO19699@dhcp22.suse.cz>
 <20170118221850.GF9171@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
        Andy Lutomirski <luto@amacapital.net>,
        David Ahern <dsahern@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        Daniel Mack <daniel@zonque.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53223 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750924AbdASJAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 04:00:16 -0500
Content-Disposition: inline
In-Reply-To: <20170118221850.GF9171@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed 18-01-17 14:18:50, Tejun Heo wrote:
> Hello, Michal.
> 
> On Tue, Jan 17, 2017 at 02:58:30PM +0100, Michal Hocko wrote:
> > This would require using hierarchical cgroup iterators to iterate over
> 
> It does behave hierarchically.
> 
> > tasks. As per Andy's testing this doesn't seem to be the case. I haven't
> 
> That's not what Andy's testing showed.  What that showed was that
> program in a child can override the one from its ancestor.

My fault, I've misread Andy's test case. I thought that the child group
simply disabled the bpf program and the one from the parent hasn't
executed.
-- 
Michal Hocko
SUSE Labs
