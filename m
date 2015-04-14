From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH linux-next 1/4] infiniband/ipoib: fix possible NULL pointer
 dereference in ipoib_get_iflink
Date: Tue, 14 Apr 2015 17:49:55 +0200
Message-ID: <552D3723.9050706@6wind.com>
References: <1429024817-21561-1-git-send-email-honli@redhat.com> <1429024817-21561-2-git-send-email-honli@redhat.com> <1429025673.7346.37.camel@edumazet-glaptop2.roam.corp.google.com> <20150414154422.GB21856@honli.nay.redhat.com>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, alex.estrin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Honggang LI <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150414154422.GB21856-9l7K0WC0B0wP68cbUhXDDlaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 14/04/2015 17:44, Honggang LI a =E9crit :
> On Tue, Apr 14, 2015 at 08:34:33AM -0700, Eric Dumazet wrote:
>> On Tue, 2015-04-14 at 23:20 +0800, Honggang Li wrote:
>>> Starting monitoring for VG vg_rdma01:   3 logical volume(s) in volu=
me
>>> group "vg_rdma01" monitored
>>> [  OK  ]
>>
>>
>>> CR2: 0000000000000120
>>> ---[ end trace a8610f6e9640eb85 ]---
>>>
>>> Signed-off-by: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>
>> When was this bug added ?
>>
>
> Sorry, I do not know. I ran into this bug today when I'm tracing a ra=
ce
> condition issue related qib. In order to check upstream linux-next fi=
x
> the race condition or not, I build linux-next-20150414 on two machine=
s. Both
> machines panic at modprobe ib_ipoib. Do you means I need to report a
> bug? But I do not know report to who or where.

Here is the tag:
=46ixes: 5aa7add8f14b ("infiniband/ipoib: implement ndo_get_iflink")

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
