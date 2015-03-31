From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ethernet: Use bool function returns of
 true/false instead of 1/0
Date: Tue, 31 Mar 2015 12:49:31 -0700
Message-ID: <1427831371.18175.18.camel@perches.com>
References: <201503260524.AdqSbov9%fengguang.wu@intel.com>
	 <20150325215525.GA26868@athens>
	 <20150329.121655.2092434262655191613.davem@davemloft.net>
	 <1427678712.2715.52.camel@perches.com> <551A80AE.7020506@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Michal Simek <michal.simek@xilinx.com>,
	=?ISO-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>
To: monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <551A80AE.7020506@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(shortened cc list)

On Tue, 2015-03-31 at 13:10 +0200, Michal Simek wrote:
> On 03/30/2015 03:25 AM, Joe Perches wrote:
> > Use bool constants as the return values instead of 1 and 0.
[]
> > diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/driver=
s/net/ethernet/xilinx/xilinx_emaclite.c
> > index 2111b91..6008eee 100644
> > --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> > +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> > @@ -1062,7 +1062,7 @@ static bool get_bool(struct platform_device *=
ofdev, const char *s)
> >  	} else {
> >  		dev_warn(&ofdev->dev, "Parameter %s not found,"
> >  			"defaulting to false\n", s);
> > -		return 0;
> > +		return false;
> >  	}
> >  }
>=20
> Kernel-doc should be also fixed in spite of this whole function is ju=
st
> broken and binding should be fixed to use of_property_read_bool for
> these properties.

Hi Michal.

David's applied this so if you or S=F6ren want to fix up
the function and kernel-doc to your taste, please do.

cheers, Joe
