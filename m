From: Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>
Subject: Fw: Cannot register at bugzilla (bugreport added) [
 ath5k bugreport ]
Date: Fri, 25 Sep 2009 19:15:24 +0200
Message-ID: <20090925191524.7b2b228c@schatten>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Hans-J. Ullrich" <hans.ullrich-LYJP0WDo+eM@public.gmane.org>
Return-path: <ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
List-Unsubscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ath5k.org/pipermail/ath5k-devel>
List-Post: <mailto:ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
List-Help: <mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=subscribe>
Sender: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
Errors-To: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
List-Id: netdev.vger.kernel.org

cc's added

could you also:
 - tell the version of the broken kernel, 
 - the last working kernel version, 
 - test if it works with current kernel-snapshot from
   http://www.kernel.org/ 

(if you are unshure about what to include in future bugreports, i feel
like this is a good guide for reporting bug's: 
http://www.kernel.org/pub/linux/docs/lkml/reporting-bugs.html )


Begin forwarded message:

Date: Tue, 8 Sep 2009 15:07:25 +0200
From: "Hans-J. Ullrich" <hans.ullrich-LYJP0WDo+eM@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Newsgroups: gmane.linux.kernel
Subject: Cannot register at bugzilla (bugreport added)


Hi dear webmasters,

sorry to write to you, but I was not able to register at
bugzilla.kernel.org.

I tried two e-mail adresses: hans.ullrich-LYJP0WDo+eM@public.gmane.org and
kontakt-beUMQNMGC1D5t8C4jrjcsg@public.gmane.org

Ther reasonn why I wanted to register is a bugreport for the kernel
module "ath5k". It would be nice, if you can register me, and maybe
send this bugreport to the nice maintainer of ath5k.

The bugreport is as follows:

---------------------------------- snip
--------------------------------------

kernel-module "ath5k" gets no IP when using dhcp


Description: It is not possible, to get an IP-address by using dhcp
with the kernel-module ath5k. It is possible, to give a fixed IP to
that module.

It seems, the kernel-module is not recognizing dhcp-offers (I remember,
this problem appeared in some versions of madwifi-driver, too),
although sometimes it seems to work, mostly, when the device already
got an IP.

If you ask me, I would define this behaviour as "very, very unstable".

This is the output in console:

# iwconfig wlan0 key off essid UIT-mobile mode managed
# dhclient -s 192.168.1.5 wlan0

Internet Systems Consortium DHCP Client V3.1.2p1
Copyright 2004-2009 Internet Systems Consortium.
All rights reserved.
For info, please visit http://www.isc.org/sw/dhcp/

Listening on LPF/wlan0/00:1d:d9:4c:88:10
Sending on   LPF/wlan0/00:1d:d9:4c:88:10
Sending on   Socket/fallback
DHCPDISCOVER on wlan0 to 192.168.1.5 port 67 interval 4
DHCPDISCOVER on wlan0 to 192.168.1.5 port 67 interval 10
DHCPDISCOVER on wlan0 to 192.168.1.5 port 67 interval 14
DHCPDISCOVER on wlan0 to 192.168.1.5 port 67 interval 12
DHCPDISCOVER on wlan0 to 192.168.1.5 port 67 interval 10
DHCPDISCOVER on wlan0 to 192.168.1.5 port 67 interval 10
DHCPDISCOVER on wlan0 to 192.168.1.5 port 67 interval 1
No DHCPOFFERS received.
No working leases in persistent database - sleeping.

#

------------------------ snap -------------------------------

I hope this helps a little bit. I will be pleased, if I can help you
more, so feel free to ask for more information. 

There are already other reports of this problem in discussion forums.
It seems, the old madwifi-driver works better with dhcp - so people say.


Thank you for your help! And thank you for your patience because of
this unusual bugreporting, I apologize for that!


Best regards

Hans-J. Ullrich
