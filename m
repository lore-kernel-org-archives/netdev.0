From: Sam Leffler <sam@errno.com>
Subject: Re: Prism54 WPA Support - wpa_supplicant - Linux general wpa support
Date: Wed, 2 Jun 2004 09:28:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406020928.07513.sam@errno.com>
References: <20040602071449.GJ10723@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez),
        Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org,
        Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hostap@shmoo.com
In-Reply-To: <20040602071449.GJ10723@ruslug.rutgers.edu>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 02 June 2004 12:14 am, Luis R. Rodriguez wrote:
> So WPA is now a priority for prism54 development. Here's where we're at.
> Long ago in January Jouni had added some wpa supplicant support into
> prism54. It's not until today when I started looking into
> wpa_supplicant.
>
> I'm glad wpa_supplicant exists :). Interacting with it *is* our missing
> link to getting full WPA support (great job Jouni). In wpa_supplicant
> cvs I see a base code for driver_prism54.c (empty routines, just providing
> skeleton). Well I'll be diving in it now and see where I can get. If anyone
> else is interested in helping with WPA support for prism54, working with
> wpa_supplicant is the way to go.
>
> I'm curious though -- wpa_supplicant is pretty much userspace. This was
> done with good intentions from what I read but before we get dirty
> with wpa_supplicant I'm wondering if we should just integrate a lot of
> wpa_supplicant into kernel space (specifically wireless tools).
> Regardless, as Jouni points out, there is still a framework for WPA that
> needs to be written for all linux wireless drivers, whether it's to assist
> wpa_supplicant framework or to integrate wpa_supplicant into kernel space.
>
> What's the plan?

I think wpa_supplicant takes the right approach (i.e. putting the majority of 
the code in user space).  The supplicant is not performance intensive and 
there's little justification for it going in the kernel on other grounds 
(like security).  I've had madwifi working with wpa_supplicant for quite a 
while and have also done a rough port of wpa_supplicant to the bsd world too 
so it's design is proven (and in general I think it's excellent work).

I'd second Jouni's comments about moving the wireless extensions support 
forward.  Aside from WPA there are a few private mechanisms required for 
multi-mode devices that should be handled through a standard API.

	Sam
