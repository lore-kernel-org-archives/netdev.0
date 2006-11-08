From: "Amit S. Kale" <amitkale@linsyssoft.com>
Subject: Re: [PATCH 1/3] NetXen: Fixed /sys mapping between device and driver
Date: Wed, 8 Nov 2006 11:37:20 +0530
Message-ID: <200611081137.21083.amitkale@linsyssoft.com>
References: <Pine.LNX.4.64.0611070818320.26206@dut39> <Pine.LNX.4.64.0611070835060.26206@dut39> <200611071749.11359.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	jeff@garzik.org, Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, wendyx@us.ibm.com,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:8256 "EHLO
	svr68.ehostpros.com") by vger.kernel.org with ESMTP
	id S1754338AbWKHGHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 01:07:16 -0500
To: Ingo Oeser <netdev@axxeo.de>
In-Reply-To: <200611071749.11359.netdev@axxeo.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ingo,

Will do.
Thanks for reviewing it.
-Amit

On Tuesday 07 November 2006 22:19, Ingo Oeser wrote:
> Hi Amit,
>
> one minor nitpick:
>
> You wrote:
> > diff --git a/drivers/net/netxen/netxen_nic_main.c
> > b/drivers/net/netxen/netxen_nic_main.c index b54ea16..4effb87 100644
> > --- a/drivers/net/netxen/netxen_nic_main.c
> > +++ b/drivers/net/netxen/netxen_nic_main.c
>
> [...]
>
> > @@ -1040,7 +1041,7 @@ static int netxen_nic_poll(struct net_de
> >   		netxen_nic_enable_int(adapter);
> >   	}
> >
> > -	return (done ? 0 : 1);
> > +	return (!done);
>
> 	return !done;
>
> Please lose the braces here (CodingStyle).
>
> Just respin or send this change along with later patchsets.
>
> Regards
>
> Ingo Oeser
