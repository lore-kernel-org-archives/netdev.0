From: YOSHIFUJI Hideaki <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Subject: Re: [PATCHv2 bluetooth-next 00/10] 6lowpan: introduce basic
 6lowpan-nd
Date: Fri, 13 May 2016 11:59:33 +0900
Message-ID: <57354315.2050509@miraclelinux.com>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <D212A5BF-A414-403B-A409-1F8C2D279883@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org,
	Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>,
	Linux Bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <D212A5BF-A414-403B-A409-1F8C2D279883-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Marcel Holtmann wrote:
> Hi Dave,
:
>> include/linux/netdevice.h     |   6 +-
>> include/net/6lowpan.h         |  24 ++
>> include/net/addrconf.h        |   3 +
>> include/net/ndisc.h           | 124 ++++++++-
>> net/6lowpan/6lowpan_i.h       |   2 +
>> net/6lowpan/Makefile          |   2 +-
>> net/6lowpan/core.c            |  50 +++-
>> net/6lowpan/iphc.c            | 167 +++++++++--
>> net/6lowpan/ndisc.c           | 633 ++++++++++++++++++++++++++++++++++++++++++
>> net/bluetooth/6lowpan.c       |   2 +
>> net/ieee802154/6lowpan/core.c |  12 +
>> net/ieee802154/6lowpan/tx.c   | 107 ++++---
>> net/ipv6/addrconf.c           |   7 +-
>> net/ipv6/ndisc.c              | 132 +++++----
>> net/ipv6/route.c              |   4 +-
>> 15 files changed, 1117 insertions(+), 158 deletions(-)
>> create mode 100644 net/6lowpan/ndisc.c
> 
> is there a chance that we get input into this patch set? I wonder also if it would be acceptable to take this through bluetooth-next or should it better go straight into net-next?

The core idea of introducing ndisc_ops is okay, but I do think this
series of patches should be refactored; we should not make another
"copy" of core of ndisc logic.  We can introduce "ops" for each
option, for example.

Thank you.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Technical Division, MIRACLE LINUX CORPORATION
