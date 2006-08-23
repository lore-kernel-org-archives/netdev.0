From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 1/2] Add Sonics Silicon Backplane driver
Date: Wed, 23 Aug 2006 13:01:53 +0200
Message-ID: <200608231301.53411.mb@bu3sch.de>
References: <200608231158.06178.mb@bu3sch.de> <200608231159.59363.mb@bu3sch.de>
	<20060823105955.GB9627@unjust.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Martin Michlmayr <tbm-R+vWnYXSFMfQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <20060823105955.GB9627-V8GU40kGihUigzW5ZibpNwC/G2K4zDHf@public.gmane.org>
Content-Disposition: inline
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

On Wednesday 23 August 2006 12:59, Martin Michlmayr wrote:
> * Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> [2006-08-23 11:59]:
> > +#define SSB_SPROM1_OEM			0x1076	/* 8 bytes OEM string (rev 1 only) */
> > +/* SPROM Revision 2 (inherits from rev 1) */
> > +#define SSB_SPROM2_BFLHI		0x1038	/* Boardflags (high 16 bits) */
> > +#define SSB_SPROM2_MAXP_A		0x103A	/* A-PHY Max Power */
> > +#define  SSB_SPROM2_MAXP_A_HI		0x00FF	/* Max Power High */
> > +#define  SSB_SPROM2_MAXP_A_LO		0x1100	/* Max Power Low */
> > +#define  SSB_SPROM2_MAXP_A_LO_SHIFT	8
> > +#define SSB_SPROM2_PA1LOB0		0x103C	/* A-PHY PowerAmplifier Low Settings */
> > +#define SSB_SPROM2_PA1LOB1		0x103E	/* A-PHY PowerAmplifier Low Settings */
> > +#define SSB_SPROM2_PA1LOB2		0x1040	/* A-PHY PowerAmplifier Low Settings */
> > +#define SSB_SPROM2_PA1HIB0		0x1042	/* A-PHY PowerAmplifier High Settings */
> > +#define SSB_SPROM2_PA1HIB1		0x1044	/* A-PHY PowerAmplifier High Settings */
> > +#define SSB_SPROM2_PA1HIB2		0x1046	/* A-PHY PowerAmplifier High Settings */
> > +#define SSB_SPROM2_OPO			0x1078	/* OFDM Power Offset from CCK Level */
> > +#define  SSB_SPROM2_OPO_VALUE		0x00FF
> > +#define  SSB_SPROM2_OPO_UNUSED		0xFF00
> > +#define SSB_SPROM2_CCODE		0x107C	/* Two char Country Code */
> 
> This is badly formated.  Can you repost, please.

Uhm, no? I don't think the formating is broken.
Please _apply_ that diff and look again at the resulting file.

(I the issue is the tabs that go crazy, if the additional diff
plus char at the beginning is inserted)

-- 
Greetings Michael.
