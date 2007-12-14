From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] PS3: gelic: Add wireless support for PS3
Date: Fri, 14 Dec 2007 07:58:47 -0500
Message-ID: <1197637127.16724.1.camel@localhost.localdomain>
References: <20071213211626.BF8E.MOKUNO@sm.sony.co.jp>
	 <1197580418.14270.6.camel@localhost.localdomain>
	 <20071214134918.275E.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org,
	Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>
To: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071214134918.275E.MOKUNO-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-12-14 at 14:03 +0900, Masakazu Mokuno wrote:
> On Thu, 13 Dec 2007 16:13:38 -0500
> Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > One more question; does the driver work with wpa_supplicant for WPA, or
> > does the firmware capture the EAPOL frames and handle the 4 way
> > handshake internally?  Ideally the firmware would have the ability to
> > pass those frames up unmodified so the driver would at least have a
> > _hope_ of 802.1x capability.  Does the firmware handle Dynamic WEP at
> > all?
> > 
> > Basically, what happens when the AP you've just associated with starts
> > sending you EAPOL traffic to start the 802.1x process?
> 
> The PS3 wireless device does the association and 4way handshake in its
> firmware/hypervisor.  No interventions between them are allowed to the guest
> OSes.  
> All frames which are sent/received from/to before the connection process
> completed seems to be dropped by the hardware.  Only the static WEP is
> supported.

That sort of sucks; but I guess there's not too much you can do about
it.  That probably means that using wpa_supplicant + WPA is completely
out of the picture, which unfortunately makes the PS3 wireless unlike
any other card, which would require special-casing the PS3 in userspace
tools.

Dan
