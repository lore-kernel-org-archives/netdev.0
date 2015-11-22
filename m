From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH 1/2 iptables] libxt_cgroup: prepare for multi revisions
Date: Sun, 22 Nov 2015 21:34:47 +0100
Message-ID: <20151122203447.GA3267@salvia>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
 <20151121161846.GB3428@htj.duckdns.org>
 <20151122203128.GA3029@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
	daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org, ninasc-b10kYP2dOMg@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151122203128.GA3029@salvia>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 22, 2015 at 09:31:28PM +0100, Pablo Neira Ayuso wrote:
> On Sat, Nov 21, 2015 at 11:18:46AM -0500, Tejun Heo wrote:
> > --- a/extensions/libxt_cgroup.c
> > +++ b/extensions/libxt_cgroup.c
> > @@ -3,30 +3,30 @@
> >  #include <linux/netfilter/xt_cgroup.h>
> >  
> >  enum {
> > -	O_CGROUP = 0,
> > +	O_CLASSID = 0,
> >  };
> >  
> > -static void cgroup_help(void)
> > +static void cgroup_help_v0(void)
> >  {
> >  	printf(
> >  "cgroup match options:\n"
> > -"[!] --cgroup fwid  Match cgroup fwid\n");
> > +"[!] --cgroup classid            Match cgroup classid\n");
> 
> We have to keep the old cgroup integer ID around for a while,
> otherwise we'll break users with old kernels and new iptables
> utilities.

Oh, I see.

This is just a rename to prepare the string based identifier.

Sorry for the noise.
