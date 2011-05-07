From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/4] [RFC] virtio-net: Improve small packet performance
Date: Sat, 7 May 2011 12:45:38 +0530
Message-ID: <OF26D73AD1.13DE7593-ON65257889.0022A7DB-65257889.0027A459@in.ibm.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com> <20110504144622.GA15823@redhat.com> <OFAEA8C363.C13C507B-ON65257886.0051F71F-65257886.0052217F@in.ibm.com> <20110504212359.GA21446@redhat.com> <OF2E0182A1.3818A07E-ON65257887.00225EE8-65257887.002C000C@in.ibm.com> <20110505090439.GD17647@redhat.com> <OFB1ACC9EB.4567C1B1-ON65257887.0050044B-65257887.0054A5CE@in.ibm.com> <20110505153413.GC1915@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110505153413.GC1915@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 05/05/2011 09:04:13 PM:

> > I haven't tuned the threshhold, it is left it at 3/4. I ran
> > the new qemu/vhost/guest, and the results for 1K, 2K and 16K
> > are below. Note this is a different kernel version from my
> > earlier test results. So, f.e., BW1 represents 2.6.39-rc2,
> > the original kernel; while BW2 represents 2.6.37-rc5 (MST's
> > kernel).
>
> Weird. My kernel is actually 2.6.39-rc2. So which is which?

I cloned git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git

# git branch -a
  vhost
* vhost-net-next-event-idx-v1
  remotes/origin/HEAD -> origin/vhost
  remotes/origin/for-linus
  remotes/origin/master
  remotes/origin/net-2.6
  remotes/origin/vhost
  remotes/origin/vhost-broken
  remotes/origin/vhost-devel
  remotes/origin/vhost-mrg-rxbuf
  remotes/origin/vhost-net
  remotes/origin/vhost-net-next
  remotes/origin/vhost-net-next-event-idx-v1
  remotes/origin/vhost-net-next-rebased
  remotes/origin/virtio-layout-aligned
  remotes/origin/virtio-layout-minimal
  remotes/origin/virtio-layout-original
  remotes/origin/virtio-layout-padded
  remotes/origin/virtio-publish-used

# git checkout vhost-net-next-event-idx-v1
Already on 'vhost-net-next-event-idx-v1'

# head -4 Makefile
VERSION = 2
PATCHLEVEL = 6
SUBLEVEL = 37
EXTRAVERSION = -rc5

I am not sure what I am missing.

thanks,

- KK

