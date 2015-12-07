From: Gilad Avidov <gavidov@codeaurora.org>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Mon, 7 Dec 2015 16:47:50 -0700
Message-ID: <20151207164750.62992b54@gavidov-lnx.qualcomm.com>
References: <1449529094-10922-1-git-send-email-gavidov@codeaurora.org>
	<56661730.4050801@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	sdharia@codeaurora.org, linux-arm-msm@vger.kernel.org,
	linux-kernel@vger.kernel.org, vikrams@codeaurora.org,
	shankerd@codeaurora.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <56661730.4050801@openwrt.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Dec 2015 00:33:04 +0100
Felix Fietkau <nbd@openwrt.org> wrote:


> On 2015-12-07 23:58, Gilad Avidov wrote:
> > +/* RRD (Receive Return Descriptor) */
> > +union emac_rrd {
> > +	struct {
> > +		/* 32bit word 0 */
> > +		u32  xsum:16;
> > +		u32  nor:4;       /* number of RFD */
> > +		u32  si:12;       /* start index of rfd-ring */
> > +		/* 32bit word 1 */
> > +		u32  hash;
> > +		/* 32bit word 2 */
> You should never use bitfields for hardware structs.
> I think in general, kernel code should be made endian safe, even if
> you only care about one particular endian type for your platform.
> 
> - Felix

Thank you Felix,
I will change the bit fields to bitwise operations and macros.

Gilad
