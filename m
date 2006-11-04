From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Drain TX status before starting IRQs
Date: Sat, 04 Nov 2006 10:38:06 -0600
Message-ID: <454CC1EE.7020708@lwfinger.net>
References: <200610191729.35402.mb@bu3sch.de> <45498633.7040808@lwfinger.net>
	<1162457146.3241.13.camel@ux156>
	<20061103165627.GC16894@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
In-Reply-To: <20061103165627.GC16894-T6t7IcXamKWaos4igUoMUw@public.gmane.org>
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

Jouni Malinen wrote:
> On Thu, Nov 02, 2006 at 09:45:46AM +0100, Johannes Berg wrote:
>> On Wed, 2006-11-01 at 23:46 -0600, Larry Finger wrote:
>>> Has anyone used this patch, particularly with WPA encryption? When I try it, wpa_supplicant 
>>> immediately uses 90+% of the cpu and never actually authenticates with my AP. I wonder if it is 
>>> something with my system.
> 
> What does wpa_supplicant do here? Have you looked at the debug log? Is
> it in some kind of busy loop doing something?

I started wpa_supplicant in the foreground with the -w and -ddd options. When the BCM4306 card was 
plugged in, the following was output (this is hand transcribed and may not be exact):

Added interface wlan0
Ignore event for foreign ifindex 8
l2_packet_receive - recvfrom: Network is down
Ignore event for foreign ifindex 8
State: DISCONNECTED -> SCANNING
Starting AP scan (specific SSID)
Scan SSID - hexdump_ascii (len = 6)
         6c 77 66 64 6a 66               lwfdjf
ioctl[SIOGSIWSCAN]: No such device
Failed to initiate AP scan.
Setting scan request: 10 sec 0 usec
Ignore event for foreign ifindex 8

At this point, the system was in the state described earlier. I could not kill wpa_supplicant nor do 
anything else, and had to power off to recover.

Larry
