From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Fwd: Weird linux kernel behavior - ARP - V2.6.16
Date: Wed, 14 Dec 2011 15:57:36 -0800
Message-ID: <CA+55aFzZHMd=pCUum3dr+Lz+i1KJfooqNT2fi8Fumq3c8BexkA@mail.gmail.com>
References: <CAGeZV=TeKwzhpxsEV_rNa0=R-RYZfy6qi0iLoZ5Y4tSA8Ti5qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39870 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755595Ab1LNX57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 18:57:59 -0500
Received: by wgbdr13 with SMTP id dr13so2684894wgb.1
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 15:57:57 -0800 (PST)
In-Reply-To: <CAGeZV=TeKwzhpxsEV_rNa0=R-RYZfy6qi0iLoZ5Y4tSA8Ti5qA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sent to some wrong people. Is anybody interested in this particular
misconfiguration? Is it intentional/wanted, or just a "don't do that
then"?

                      Linus


---------- Forwarded message ----------
From: Isaac Theogaraj <isaactheogaraj@gmail.com>
Date: Wed, Dec 14, 2011 at 1:59 AM
Subject: Weird linux kernel behavior - ARP - V2.6.16
To: torvalds@osdl.org
Cc: mtosatti@redhat.com, alan@lxorguk.ukuu.org.uk, tao@acc.umu.se


Dear Kernel experts,
I just encountered a kernel behavior wherein if the default gateway is
set as an interface IP itself,
kernel starts ARPing for every internet address.
Would like to what is the intention behind this behavior?

Of course this is an inadvertent configuration(wrong config. too), but
when kernel ARPs for
all internet addresses, that bloats up network tables in the
routing/bridging devices.

Logically speaking, if I say "My default gateway is me", then it's
like saying that I have all routes
and ARP resolutions. If I don't have a connected network for a
destination, I drop it.

Can you please let me know, why is the behavior set as "ARPing for
every internet address" when
"Default gateway is me"?
thanks in advance,
Isaac.
