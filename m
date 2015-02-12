From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: bride: IPv6 multicast snooping enhancements
Date: Thu, 12 Feb 2015 12:41:17 +0100
Message-ID: <20150212114117.GC3665@odroid>
References: <1378253619-23918-1-git-send-email-linus.luessing@web.de>
 <54D9C4ED.6040601@parallels.com> <20150210114428.GK2489@odroid>
 <54DA0EAD.60002@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Cong Wang <amwang@redhat.com>
To: Vasily Averin <vvs@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54DA0EAD.60002@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 04:59:09PM +0300, Vasily Averin wrote:
> I'm trying to fix ICMPv6 processing broken in OpenVZ after rebase to last RHEL6u6 kernel.
> After some unclear manipulation bridge begins to forward icmp6 NS (fe02::1) into wrong port,
> and at present I do not found the reason of this failure.

fe02::1 seems uncommon for ICMPv6 NS messages. Would you mind
making some dumps for ~10 minutes with tcpdump on all bridge ports
and the bridge interface itself with a filter "icmp6" and uploading the
result somewhere?

Also provide a dump from "bridge mdb show dev $bridge" please (if
possible - not sure whether that's available on the ancient 2.6.32
kernel as used on RHEL6u6).

Cheers, Linus
