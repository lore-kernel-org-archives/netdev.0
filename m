From: kuznet@ms2.inr.ac.ru
Subject: Re: Resend:  SIOCGIFBRDADDR?
Date: Thu, 15 Aug 2002 20:35:59 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208151635.UAA27112@sex.inr.ac.ru>
References: <Pine.LNX.4.44.0208151205240.9904-100000@kaneda.isrd.lan>
Mime-Version: 1.0
Cc: alanr@unix.sh, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kevin@pheared.net (Kevin Dwyer)
In-Reply-To: <Pine.LNX.4.44.0208151205240.9904-100000@kaneda.isrd.lan> from "Kevin Dwyer" at Aug 15, 2 12:10:11 pm
List-Id: netdev.vger.kernel.org

Hello!

> crazy.  So my question: Does anyone know if there's an ip route command to
> make the Bcast field show up as the correct value,

Yes, that one which is described in manual (and equivalent to corresponding
ifconfig)

ifconfig eth0:tra-ta-ta 10.x.y.z etc.


>				      or is there a better
> way for heartbeat to get the broadcast address?

Well, yes. Initialize ifreq with right address, for instance.
Probably, your program has the same problem, which is in net-tools package.


Or this:

> That command gives me the correct broadcast address in the brd field.

Alexey
