From: Dexuan Cui <decui-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
Subject: RE: [PATCH net-next] net, cgroup: cgroup_sk_updat_lock was missing
 initializer
Date: Tue, 15 Dec 2015 02:11:20 +0000
Message-ID: <9f79b2053ba7422b816cfc34d380e5d6@HKXPR3004MB0088.064d.mgd.msft.net>
References: <1449527935-27056-1-git-send-email-tj@kernel.org>
	<f90d369a0e004fee8d3bfdfe95e0abc0@HKXPR3004MB0088.064d.mgd.msft.net>
	<20151214162406.GA4026@mtj.duckdns.org>
 <20151214.142043.1185024338854399910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org" <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org" <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	"kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org" <kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>,
	"daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org" <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	"daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org" <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org" <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	"hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org" <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org" <coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"kernel-team-b10kYP2dOMg@public.gmane.org" <kernel-team-b10kYP2dOMg@public.gmane.org>,
	"ninasc-b10kYP2dOMg@public.gmane.org" <ninasc-b10kYP2dOMg@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151214.142043.1185024338854399910.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-US
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]
> Sent: Tuesday, December 15, 2015 3:21
> To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
> Cc: Dexuan Cui <decui-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>; pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org; kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org;
> kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org; daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org; daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org;
> nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org; lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org; hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org;
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org; cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; kernel-team-b10kYP2dOMg@public.gmane.org; ninasc-b10kYP2dOMg@public.gmane.org
> Subject: Re: [PATCH net-next] net, cgroup: cgroup_sk_updat_lock was missing
> initializer
> 
> From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Date: Mon, 14 Dec 2015 11:24:06 -0500
> 
> > bd1060a1d671 ("sock, cgroup: add sock->sk_cgroup") added global
> > spinlock cgroup_sk_update_lock but erroneously skipped initializer
> > leading to uninitialized spinlock warning.  Fix it by using
> > DEFINE_SPINLOCK().
> >
> > Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > Reported-by: Dexuan Cui <decui-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
> > Fixes: bd1060a1d671 ("sock, cgroup: add sock->sk_cgroup")
> 
> Applied, thanks.

Thanks! I can confirm it fixed the issue.

Thanks,
-- Dexuan
