From: Bodo Eggert <harvested.in.lkml@posting.7eggert.dyndns.org>
Subject: Re: [Bcm43xx-dev] [Fwd: State of the Union: Wireless]
Date: Fri, 06 Jan 2006 23:57:59 +0100
Message-ID: <E1Ev0X3-0000tX-4l@be1.lrz>
References: <5rXDU-5s4-7@gated-at.bofh.it> <5rXDU-5s4-5@gated-at.bofh.it>
Reply-To: 7eggert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964985AbWAFWy2@vger.kernel.org>
To: Michael Buesch <mbuesch@freenet.de>, jgarzik@pobox.com,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch <mbuesch@freenet.de> wrote:

> How would the virtual interfaces look like? That is quite easy to ans=
wer.
> They are net_devices, as they transfer data.
> They should probaly _not_ be on top of the ethernet, as 80211 does no=
t
> have very much in common with ethernet. Basically they share the same
> MAC address format. Does someone have another thing, which he thinks
> is shared?

<brainstorming>

It has a connection status.
It has a connection speed, which is less static than on a LAN.
(Maybe it can be asynchronous in the next version.)
It can't yet be full duplex, but who knows ...
It can be in promiscious mode (wardriving).

> The virtual interface is then configured though /dev/wlan0 using writ=
e()
> (no ugly ioctl anymore, you see...). Config data like TX rate,
> current essid,.... basically everything + xyz which is done by WE tod=
ay,
> is written to /dev/wlan0.

In ASCII parsed by an in-kernel library? Did you consider sysfs?

What would a connection manager look for if it's supposed to act on
* plugging in the WLAN card
* finding/losing a (better) network

--=20
Ich danke GMX daf=FCr, die Verwendung meiner Adressen mittels per SPF
verbreiteten L=FCgen zu sabotieren.
