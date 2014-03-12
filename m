From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v3 5/9] Altera TSE: Add Miscellaneous Files for
 Altera Ethernet Driver
Date: Wed, 12 Mar 2014 14:27:34 -0700
Message-ID: <1394659654.3915.54.camel@joe-AO722>
References: <1394577791-6547-1-git-send-email-vbridgers2013@gmail.com>
	 <1394577791-6547-6-git-send-email-vbridgers2013@gmail.com>
	 <1394578747.28839.4.camel@joe-AO722>
	 <CAOwfj2Ot+ssTZgMoOoShVEUi+RkxjpPpRUfHAkP9RETm3TuUzg@mail.gmail.com>
	 <1394658856.20857.7.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Vince Bridgers <vbridgers2013@gmail.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1394658856.20857.7.camel@deadeye.wl.decadent.org.uk>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(added David Miller to cc's)

On Wed, 2014-03-12 at 21:14 +0000, Ben Hutchings wrote:
> On Tue, 2014-03-11 at 19:28 -0500, Vince Bridgers wrote:
> > On Tue, Mar 11, 2014 at 5:59 PM, Joe Perches <joe@perches.com> wrote:
> > > On Tue, 2014-03-11 at 17:43 -0500, Vince Bridgers wrote:
> > >> This patch adds miscellaneous files for the Altera Ethernet Driver,
> > >> including ethtool support.
> > > trivial notes:
> > >> diff --git a/drivers/net/ethernet/altera/altera_tse_ethtool.c b/drivers/net/ethernet/altera/altera_tse_ethtool.c
> > > []
> > >> +static char const stat_gstrings[][ETH_GSTRING_LEN] = {
> > > static const char
> > >> +     "aFramesTransmittedOK",
> > > Why the prefix with a?
> > These names follow the names of the statistics found in the databook
> > for the Altera Triple Speed Ethernet (TSE) soft IP. I'm not
> > emotionally attached to these names, so will review the statistics
> > names and follow common usage instead. Thank you for noticing and
> > commenting.
> [...]
> 
> These look like the statistic names specified in IEEE 802.3.

Yup.

> I would
> support a general move to using standard names for MAC stats in Ethernet
> drivers, because they are quite clearly defined and widely implemented
> in hardware.  However, that is not the current practice in most Linux
> drivers.

It was kind of an odd mix of rfc 2666 and 3635 names.

I think the v4 patch naming is at least more consistent
with the rest of the kernel and "thanks Vince" for
changing it.

Maybe it wouldn't hurt to have some more #defines for
these strings and use them in all the drivers.


