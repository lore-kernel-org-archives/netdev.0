From: David Brownell <david-b@pacbell.net>
Subject: B43 on Inspiron 1545 w/Ubuntu
Date: Sun, 28 Nov 2010 20:27:00 -0800
Message-ID: <1291004820.2285.33.camel@helium>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm21-vm0.bullet.mail.ac4.yahoo.com ([98.139.53.216]:41408 "HELO
	nm21-vm0.bullet.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751600Ab0K2E1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 23:27:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Briefly, it's never worked well and I'm hoping someone can help.

The OS is currently Ubuntu 10.04.1 ... recent updates included B43
from wireless-backports, I think; I saw  One positive change,
but it still doesn't work.  (Yeah, 2.6.32 isn't recent, but I'm not
much trusting the non-existent account backup here. so an upgrade
to 10.10.x isn't yet in the cards.  And this is supposed to work
already, in any case...

History:  Didn't work at first, the driver had a DMA bug.  Based
on a forum post I installed the backports using Ethernet.  After
more setup and a few days, WLAN began working relatively well ...
for a period of maybe five days, then completely stopped working
in the middle of a webpage access (last summer).
NetworkManager kept saying wireless was disabled (and rejected all
attempts to re-enable.  10+ months passed (Ethernet works fine).

	NOTE to "NetworkManager" folk ... please fix it so that
when you select "enable wireless" it either does so, or says why it
didn't.  This "Ignore user commands" crap is garbage.  and for
that matter -- instead of  saying "disabled", try saying why/how;
I certainly never disabled WLAN. or "Networking" as a whole either,
so in that sense it's just a bug.  In particular, there was never
any explicit user "disable" action (to parallel the "enable" menu
option provided) by NM).

To my surprise and pleasure, the WLAN worked for about two
hours of  web browsing in a hotel lobby, after disconnecting from
a wired connection; no odd behaviors at all, beyond trying at first
to connect as wired, when there was no wire available.

Hasn't worked from various coffee shops either.  As if maybe something
in NetworkManager transferred state from wired to WLAN, sufficient to
make it work ... but coffee shops wouldn't support such state transfer
between my home LAN and the coffee WLAN.  (That hotel had one network
provider for both wired and WLAN/lobby).


The only other time this came close to working was on an airplane,
where it saw "gogoinflight" but crapped out after a few minutes.
(Sorry no details on how/why; maybe it would have been happier if
I'd finished signing up before it crapped out

A recent Ubuntu update changed behavior in a positive way:  when
I looked at "dmesg" (as few normal users would try to do), it
changed behavior and complained about a hardware RFKILL button.

Let it be noted that there is no such button ... but BIOS F2 is
probably what it means.  Unfortunately I can't figure out how to
make that button work ... the manual is not at best weak.  (Suggests
just press F2, not FN-F2, forums say the latter, but neither one has
worked for me .  (Plus there is no visual rfkill indication (LED
 or otherwise) as I'm used to on other hardware.  I guess on this
hardware Dell cheaped out past the point usability was affected.

 The undocumented "rfkill" command says WLAN is "hard blocked".
Puzzling, considering I've never tried to block WLAN access, and
it appears to have decided to spontaneously off itself.

I'm moderately hopeful that if I could make F2 work, then I'd
have WLAN.  Hope does spring eternal, as they say... Can someone
please offer some hints for me?

While I'm writing here, I'll just comment that NetworkManager has
seemed to make this whole thing maximally painful/mysterious.


Recent dmesg output below.


[  680.493965] b43-phy0: Broadcom 4312 WLAN found (core revision 15)
[  680.660736] phy0: Selected rate control algorithm 'minstrel'
[  680.661406] Registered led device: b43-phy0::tx
[  680.661423] Registered led device: b43-phy0::rx
[  680.661437] Registered led device: b43-phy0::radio
[  680.661519] Broadcom 43xx driver loaded [ Features: PMNLS,
Firmware-ID: FW13 ]
[  680.960280] b43-phy0: Loading firmware version 410.2160 (2007-05-26
15:32:10)
[  681.700410] b43-phy0: Radio hardware status changed to DISABLED
[  681.730361] b43-phy0: Radio turned on by software
[  681.730368] b43-phy0: The hardware RF-kill button still turns the
radio physically off. Press the button to turn it on.
[  681.731490] ADDRCONF(NETDEV_UP): wlan0: link is not ready


