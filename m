From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 01/16] mac80211: fix TX device statistics for monitor
 interfaces
Date: Mon, 28 Oct 2013 14:47:41 +0100
Message-ID: <1382968061.17956.10.camel@jlt4.sipsolutions.net>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	 <1382819655-30430-2-git-send-email-pali.rohar@gmail.com>
	 (sfid-20131026_224024_753066_57DA03E7)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com, David Gnedt <david.gnedt@davizone.at>
To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-2-git-send-email-pali.rohar@gmail.com> (sfid-20131026_224024_753066_57DA03E7)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-10-26 at 22:34 +0200, Pali Roh=C3=A1r wrote:

> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes +=3D skb->len;

We can still easily drop the packet after this - we can't guarantee
it'll go out but maybe we shouldn't do it here?

johannes
