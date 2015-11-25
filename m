From: "Lan, Tianyu" <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH V2 3/3] Ixgbevf: Add migration support for ixgbevf
 driver
Date: Thu, 26 Nov 2015 00:02:33 +0800
Message-ID: <5655DB99.3040007@intel.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
 <1448372298-28386-4-git-send-email-tianyu.lan@intel.com>
 <20151124230551-mutt-send-email-mst@redhat.com> <56554994.1090305@intel.com>
 <20151125142437-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org, alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	eddie.dong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nrupal.jani-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, agraf-l3A5Bk7waGM@public.gmane.org,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org,
	emil.s.tantilov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	mark.d.rustad-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, eric.auger-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.ronciak-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mitch.a.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shannon.nelson-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	weiyang-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151125142437-mutt-send-email-mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/25/2015 8:28 PM, Michael S. Tsirkin wrote:
> Frankly, I don't really see what this short term hack buys us,
> and if it goes in, we'll have to maintain it forever.
>

The framework of how to notify VF about migration status won't be
changed regardless of stopping VF or not before doing migration.
We hope to reach agreement on this first. Tracking dirty memory still
need to more discussions and we will continue working on it. Stop VF may
help to work around the issue and make tracking easier.


> Also, assuming you just want to do ifdown/ifup for some reason, it's
> easy enough to do using a guest agent, in a completely generic way.
>

Just ifdown/ifup is not enough for migration. It needs to restore some 
PCI settings before doing ifup on the target machine
