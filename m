From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Wed, 14 Sep 2016 13:06:29 +0200
Message-ID: <20160914110629.GA12405@pox.localdomain>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
 <20160913115627.GA4898@salvia>
 <da300784-284c-0d1f-a82e-aa0a0f8ae116@zonque.org>
 <20160913172408.GC6138@salvia>
 <20160914044217.GA44742@ast-mbp.thefacebook.com>
 <20160914103038.GA910@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160914103038.GA910@salvia>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/14/16 at 12:30pm, Pablo Neira Ayuso wrote:
> On Tue, Sep 13, 2016 at 09:42:19PM -0700, Alexei Starovoitov wrote:
> [...]
> > For us this cgroup+bpf is _not_ for filterting and _not_ for security.
> 
> If your goal is monitoring, then convert these hooks not to allow to
> issue a verdict on the packet, so this becomes inoquous in the same
> fashion as the tracing infrastructure.

Why? How is this at all offensive? We have three parties voicing
interest in this work for both monitoring and security. At least
two specific use cases have been described.  It builds on top of
existing infrastructure and nicely complements other ongoing work.
Why not both?
