From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH] PS3: gelic: Add wireless support for PS3
Date: Fri, 14 Dec 2007 14:03:13 +0900
Message-ID: <20071214134918.275E.MOKUNO@sm.sony.co.jp>
References: <20071213211626.BF8E.MOKUNO@sm.sony.co.jp> <1197580418.14270.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org,
	Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1197580418.14270.6.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Thu, 13 Dec 2007 16:13:38 -0500
Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> One more question; does the driver work with wpa_supplicant for WPA, or
> does the firmware capture the EAPOL frames and handle the 4 way
> handshake internally?  Ideally the firmware would have the ability to
> pass those frames up unmodified so the driver would at least have a
> _hope_ of 802.1x capability.  Does the firmware handle Dynamic WEP at
> all?
> 
> Basically, what happens when the AP you've just associated with starts
> sending you EAPOL traffic to start the 802.1x process?

The PS3 wireless device does the association and 4way handshake in its
firmware/hypervisor.  No interventions between them are allowed to the guest
OSes.  
All frames which are sent/received from/to before the connection process
completed seems to be dropped by the hardware.  Only the static WEP is
supported.


-- 
Masakazu MOKUNO
