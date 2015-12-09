From: "Lan, Tianyu" <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Wed, 9 Dec 2015 19:41:46 +0800
Message-ID: <5668137A.9090608@intel.com>
References: <CAKgT0Uc+-gFAetEfde6DmMOFK+vDE6UkgsNF8oLNqaQc4USSeg@mail.gmail.com>
 <565DB6FF.1050602@intel.com> <20151201171140-mutt-send-email-mst@redhat.com>
 <CAKgT0UfLEJpV-KdqRGfzBeas8bdqfHCmT5Xc8iVVP03g_pQO8A@mail.gmail.com>
 <20151201193026-mutt-send-email-mst@redhat.com>
 <CAKgT0UfJ7w6yYcZcF2YZyDKEwvE7Gh3P-jfGQGKLfPH2crVBzw@mail.gmail.com>
 <20151202105955-mutt-send-email-mst@redhat.com> <5661C000.8070201@intel.com>
 <20151209122831-mutt-send-email-mst@redhat.com> <56680E33.6040204@intel.com>
 <20151209132233-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Dong, Eddie" <eddie.dong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org" <a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org>,
	Alex Williamson <alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org" <b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org>,
	Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"Wyborny, Carolyn" <carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Skidmore, Donald C" <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Jani, Nrupal" <nrupal.jani-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Alexander Graf <agraf-l3A5Bk7waGM@public.gmane.org>,
	"kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org" <qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org>,
	"Tantilov, Emil S" <emil.s.tantilov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rustad, Mark D" <mark.d.rustad-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eric Auger <eric.auger-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	intel-wired-lan <intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151209132233-mutt-send-email-mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/9/2015 7:28 PM, Michael S. Tsirkin wrote:
> I remember reading that it's possible to implement a bus driver
> on windows if required.  But basically I don't see how windows can be
> relevant to discussing guest driver patches. That discussion
> probably belongs on the qemu maling list, not on lkml.

I am not sure whether we can write a bus driver for Windows to support
migration. But I think device vendor who want to support migration will 
improve their driver if we provide such framework in the
hypervisor which just need them to change their driver.
