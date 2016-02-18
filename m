From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [PATCH] net: fix bridge multicast packet checksum validation
Date: Thu, 18 Feb 2016 13:51:34 +0100
Message-ID: <20160218125134.GA20283@sesse.net>
References: <1455502026-23144-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	=?utf-8?B?w4FsdmFybyBGZXJuw6FuZGV6?= Rojas <noltari@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455502026-23144-1-git-send-email-linus.luessing@c0d3.blue>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 15, 2016 at 03:07:06AM +0100, Linus L=C3=BCssing wrote:
> Steinar, can you check whether this fixes the bridge issues you repor=
ted on
> bugzilla #99081? Not quite sure whether it is the same as yours as yo=
u
> do not seem to have any such call traces.

It doesn't immediately sound like the same problem; why would promisc c=
hange
anything if the problem is the checksumming?

I don't have any reboots scheduled for this machine right now, but I'll=
 see
what I can do wrt. testing.

/* Steinar */
--=20
Homepage: https://www.sesse.net/
