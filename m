From: Ray Lee <ray-lk@madrabbit.org>
Subject: Re: Bcm43xx softMac Driver in 2.6.18
Date: Sat, 23 Sep 2006 09:51:30 -0700
Message-ID: <45156612.2080906@madrabbit.org>
References: <4513E308.10507@lwfinger.net> <2c0942db0609222303o50e47156xe6af9a50ed8301c8@mail.gmail.com> <200609231141.26090.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, dbtsai@gmail.com,
	John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 242.178.36.72.reverse.layeredtech.com ([72.36.178.242]:2469
	"EHLO tapestrysystems.com") by vger.kernel.org with ESMTP
	id S1751306AbWIWQwH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 12:52:07 -0400
To: "Rafael J. Wysocki" <rjw@sisk.pl>
In-Reply-To: <200609231141.26090.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki wrote:
>> 2.6.18 vanilla and 2.6.18 with your patch both lock my system hard
>> with bcm43xx. I've got an HP/Compaq nx6125 laptop. Symptoms are that
>> it will associate fine on its own and send traffic to/fro upon ifup,
>> but when I do an iwconfig, ifdown, ifup to change the access point,
>> the system locks (somewhat randomly) during one of those operations.
>> Well, the iwconfig or the ifup, actually.
> 
> I have observed similar symptoms on HPC nx6325, although I haven't managed
> to get the adapter associate with an AP.

Yeah, I'm having the same troubles. Carefully watching the iwconfig
results showed me that only half of the time did my `iwconfig eth1 essid
AccessPointName` actually take. (It listed the essid of the ap I told it
to associate with, but then showed "Access Point: Invalid" or words to
that effect, until I issued the exact same iwconfig again.)

So, try it twice, double check the iwconfig output, then try bringing up
the interface. Though that seems awfully difficult to do as well (DHCP
is just sending out stuff with nothing coming back).

When I switch consoles while DHCP is plaintively asking for an IP, and
issue *another* iwconfig with the same essid, then it seems to kick
something in the driver and DHCP immediately associates. Happened twice
for me so far, though that could merely be a coincidence.

Ray
