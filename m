From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: b44: high ping times with wireless-dev
Date: Sun, 17 Jun 2007 04:32:40 +0200
Message-ID: <200706170432.40958.mb@bu3sch.de>
References: <200706162327.47413.maxi@daemonizer.de> <20070616154946.5fb6b013@localhost.localdomain> <200706170242.24214.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Jeff Garzik" <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	"Arnaldo Carvalho de Melo" <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
To: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200706170242.24214.maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 17 June 2007 02:42:18 Maximilian Engelhardt wrote:
> I did build a kernel without the three mentioned above but the problem is 
> still the same. I also did remove everything but eth0 on interrupt 10 so the 
> only device using that interrupt is eth0 and then the card completely stopped 
> working.

_That_ is interesting...
Maybe the IRQ isn't correctly wired up on the backplane and
it doesn't generate IRQs at all (so it only worked, because other devices
on the same IRQ line triggered the line).
I'll take a look at that code.

-- 
Greetings Michael.
