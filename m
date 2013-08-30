From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch v2] net/fec: cleanup types in fec_get_mac()
Date: Fri, 30 Aug 2013 12:00:49 +0300
Message-ID: <20130830090049.GJ19256@mwanda>
References: <20130829082514.GB14334@elgon.mountain>
 <1377802138.5372.12.camel@bwh-desktop.uk.level5networks.com>
 <9848F2DB572E5649BA045B288BE08FBE01662A4B@039-SN2MPN1-021.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Li Frank-B20596 <B20596@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Duan Fugang-B38611 <B38611@freescale.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE01662A4B@039-SN2MPN1-021.039d.mgd.msft.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 30, 2013 at 02:02:00AM +0000, Duan Fugang-B38611 wrote:
> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> Data: Friday, August 30, 2013 2:49 AM
> 
> > To: Dan Carpenter
> > Cc: Grant Likely; Rob Herring; David S. Miller; Estevam Fabio-R49496; Li
> > Frank-B20596; Jim Baxter; Duan Fugang-B38611; netdev@vger.kernel.org;
> > devicetree@vger.kernel.org; kernel-janitors@vger.kernel.org
> > Subject: Re: [patch v2] net/fec: cleanup types in fec_get_mac()
> > 
> > On Thu, 2013-08-29 at 11:25 +0300, Dan Carpenter wrote:
> > > My static checker complains that on some arches unsigned longs can be
> > > 8 characters which is larger than the buffer is only 6 chars.
> > > Additionally, Ben Hutchings points out that the buffer actually holds
> > > big endian data and the buffer we are reading from is CPU endian.
> > 
> > It's not really as clear-cut as that. :-)  But I think it's slightly more
> > logical this way.
> > 
> Yes, it is not clear, pls remove somebody's name from the commit log.

Huh?  No, I'm going to leave Ben's name as is.  It's weird that you
would ask for that.

regards,
dan carpenter

