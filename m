From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH linux-next 1/4] infiniband/ipoib: fix possible NULL
 pointer dereference in ipoib_get_iflink
Date: Tue, 14 Apr 2015 08:34:33 -0700
Message-ID: <1429025673.7346.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429024817-21561-1-git-send-email-honli@redhat.com>
	 <1429024817-21561-2-git-send-email-honli@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, alex.estrin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1429024817-21561-2-git-send-email-honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-04-14 at 23:20 +0800, Honggang Li wrote:
> Starting monitoring for VG vg_rdma01:   3 logical volume(s) in volume
> group "vg_rdma01" monitored
> [  OK  ]


> CR2: 0000000000000120
> ---[ end trace a8610f6e9640eb85 ]---
> 
> Signed-off-by: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

When was this bug added ?

Please add a proper Fixes: tag


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
