From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH] net: mv643xx_eth: Add GRO support
Date: Thu, 11 Apr 2013 18:59:11 +0200
Message-ID: <CABJ1b_QaEJbuBsqx+J1Pkc7o66S_Rboa7Trnko1mXSK6-UZhfg@mail.gmail.com>
References: <1365684023-9967-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<20130411131333.GD1910@1wt.eu>
	<CABJ1b_TQDabT1J7ffo5cb1Th=71bcSduifMJaDpfVRiiHvtWDw@mail.gmail.com>
	<20130411150326.GA19978@1wt.eu>
	<CABJ1b_TRxm97DKJLP_h0VwMJvcYmSpjoJvtg1KvBNGah=VzqMQ@mail.gmail.com>
	<20130411153256.GH1910@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linux-kernel@vger.kernel.org,
	Florian Fainelli <florian@openwrt.org>,
	Soeren Moch <smoch@web.de>, Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130411153256.GH1910@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 11, 2013 at 5:32 PM, Willy Tarreau <w@1wt.eu> wrote:
> On Thu, Apr 11, 2013 at 05:27:03PM +0200, Sebastian Hesselbarth wrote:
>> I don't have a strong opinion on whether Soeren's or your proposal should
>> be submitted. But I insist on having one of them in, as GRO significantly
>> improves the common use case, is enabled by default, and not as
>> constrained as LRO.
>
> I agree, use yours first, but we should keep an eye on this. Since you have
> everything to run a test, please try to see if you can get netperf to run
> over IPv6, I'm sure the NIC doesn't handle it.

Willy,

out of curiosity I replayed all tests using netperf/netserver with -6 which
enables ipv6. The overall results remain quite the same here:
enabling support for GRO gives a huge improvement in achievable
throughput, and the difference between Soeren's and your patch is
neglectible.

Sebastian
