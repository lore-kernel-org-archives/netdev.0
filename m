From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 4/8] tg3: Add EEE support
Date: Fri, 15 Oct 2010 11:19:04 -0700
Message-ID: <20101015181904.GA1389@mcarlson.broadcom.com>
References: <1287088665-22135-5-git-send-email-mcarlson@broadcom.com>
 <1287152246.2267.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2669 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756375Ab0JOSTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 14:19:51 -0400
In-Reply-To: <1287152246.2267.14.camel@achroite.uk.solarflarecom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 07:17:26AM -0700, Ben Hutchings wrote:
> On Thu, 2010-10-14 at 13:37 -0700, Matt Carlson wrote:
> > This patch adds Energy Efficient Ethernet (EEE) support for the 5718
> > device ID and the 57765 B0 asic revision.
> [...]
> > +/* Clause 45 expansion registers */
> > +#define TG3_CL45_D7_EEEADV_CAP		0x003c
> > +#define TG3_CL45_D7_EEEADV_CAP_100TX	0x0002
> > +#define TG3_CL45_D7_EEEADV_CAP_1000T	0x0004
> 
> I assume this is going to be a standard register, so I think it should
> be defined in <linux/mdio.h>.

O.K.  I'll make the change and respin this patch.

> > +#define TG3_CL45_D7_EEERES_STAT                0x803e
> > +#define TG3_CL45_D7_EEERES_STAT_LP_100TX	0x0002
> > +#define TG3_CL45_D7_EEERES_STAT_LP_1000T	0x0004
> 
> 0x803e not 0x003e?

I'm checking on this one.  EEE works with this patch in place.  Maybe I
can make this a definition that takes a standard clause 45 register as
an input though.

> Also Dave suggested there should be an ethtool interface to control EEE
> <http://thread.gmane.org/gmane.linux.network/164141/focus=165143>.

I don't see any ETH_FLAG definition for this in ethtool.h yet.  Is this
the way everyone wanted to go?

