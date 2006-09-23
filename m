From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Bcm43xx softMac Driver in 2.6.18
Date: Sat, 23 Sep 2006 13:00:36 -0500
Message-ID: <45157644.9020305@lwfinger.net>
References: <4513E308.10507@lwfinger.net>
	<2c0942db0609222303o50e47156xe6af9a50ed8301c8@mail.gmail.com>
	<200609231141.26090.rjw@sisk.pl> <45156612.2080906@madrabbit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Ray Lee <ray-gmail-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
In-Reply-To: <45156612.2080906-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Ray Lee wrote:
> Rafael J. Wysocki wrote:
>>> 2.6.18 vanilla and 2.6.18 with your patch both lock my system hard
>>> with bcm43xx. I've got an HP/Compaq nx6125 laptop. Symptoms are that
>>> it will associate fine on its own and send traffic to/fro upon ifup,
>>> but when I do an iwconfig, ifdown, ifup to change the access point,
>>> the system locks (somewhat randomly) during one of those operations.
>>> Well, the iwconfig or the ifup, actually.
>> I have observed similar symptoms on HPC nx6325, although I haven't managed
>> to get the adapter associate with an AP.
> 
> Yeah, I'm having the same troubles. Carefully watching the iwconfig
> results showed me that only half of the time did my `iwconfig eth1 essid
> AccessPointName` actually take. (It listed the essid of the ap I told it
> to associate with, but then showed "Access Point: Invalid" or words to
> that effect, until I issued the exact same iwconfig again.)
> 
> So, try it twice, double check the iwconfig output, then try bringing up
> the interface. Though that seems awfully difficult to do as well (DHCP
> is just sending out stuff with nothing coming back).
> 
> When I switch consoles while DHCP is plaintively asking for an IP, and
> issue *another* iwconfig with the same essid, then it seems to kick
> something in the driver and DHCP immediately associates. Happened twice
> for me so far, though that could merely be a coincidence.
> 

I don't know about the problems associating, and/or with changing APs - I have only one and it
associates and authenticates with WPA-PSK without any trouble.

As to the lockups that you are seeing, I have generated a diff between vanilla 2.6.18 and
wireless-2.6 with some essential patches added. At the moment, I'm compiling and testing it. There
are more problems with locking than I realized. If the patch works here, I'll post it to you and to
the bcm43xx list. The hard part may be getting stable to accept it for 2.6.18.1.

Thanks for the bug reports.

Larry
