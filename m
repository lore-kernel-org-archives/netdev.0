From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Date: Mon, 30 Jan 2017 08:56:27 +0100
Message-ID: <20170130075626.GC8443@dhcp22.suse.cz>
References: <20170126074354.GB8456@dhcp22.suse.cz>
 <5889C331.7020101@iogearbox.net>
 <20170126100802.GF6590@dhcp22.suse.cz>
 <5889DEA3.7040106@iogearbox.net>
 <20170126115833.GI6590@dhcp22.suse.cz>
 <5889F52E.7030602@iogearbox.net>
 <20170126134004.GM6590@dhcp22.suse.cz>
 <588A5D3C.4060605@iogearbox.net>
 <20170127100544.GF4143@dhcp22.suse.cz>
 <588BA9AA.8010805@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>,
	Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	marcelo.leitner@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <588BA9AA.8010805@iogearbox.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri 27-01-17 21:12:26, Daniel Borkmann wrote:
> On 01/27/2017 11:05 AM, Michal Hocko wrote:
> > On Thu 26-01-17 21:34:04, Daniel Borkmann wrote:
[...]
> > > So to answer your second email with the bpf and netfilter hunks, why
> > > not replacing them with kvmalloc() and __GFP_NORETRY flag and add that
> > > big fat FIXME comment above there, saying explicitly that __GFP_NORETRY
> > > is not harmful though has only /partial/ effect right now and that full
> > > support needs to be implemented in future. That would still be better
> > > that not having it, imo, and the FIXME would make expectations clear
> > > to anyone reading that code.
> > 
> > Well, we can do that, I just would like to prevent from this (ab)use
> > if there is no _real_ and _sensible_ usecase for it. Having a real bug
> 
> Understandable.
> 
> > report or a fallback mechanism you are mentioning above would justify
> > the (ab)use IMHO. But that abuse would be documented properly and have a
> > real reason to exist. That sounds like a better approach to me.
> > 
> > But if you absolutely _insist_ I can change that.
> 
> Yeah, please do (with a big FIXME comment as mentioned), this originally
> came from a real bug report. Anyway, feel free to add my Acked-by then.

Thanks! I will repost the whole series today.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
