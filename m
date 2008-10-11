From: Guennadi Liakhovetski <lg@denx.de>
Subject: Re: [PATCH, RFC] Extend smc911x to support LAN921x chips
Date: Sat, 11 Oct 2008 11:00:40 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0810111057030.4425@axis700.grange>
References: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
 <87vdx5gjzo.fsf@macbook.be.48ers.dk> <Pine.LNX.4.64.0810110125540.10196@axis700.grange>
 <871vynr3yb.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steve.Glendinning@smsc.com, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:59202 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750756AbYJKJAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2008 05:00:38 -0400
In-Reply-To: <871vynr3yb.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 11 Oct 2008, Peter Korsgaard wrote:

> >>>>> "Guennadi" == Guennadi Liakhovetski <lg@denx.de> writes:
> 
> It looks good, but you should definately split out the arm and cleanup
> stuff from the new IDs.

You mean remove the new IDs? Why?

>  Guennadi> @@ -722,6 +724,9 @@ static void smc911x_phy_detect(struct net_device *dev)
>  Guennadi>  						break;
>  Guennadi>  					}
>  Guennadi>  				}
>  Guennadi> +				if (phyaddr < 32)
>  Guennadi> +					/* Found an external PHY */
>  Guennadi> +					break;
> 
> What's this for? Isn't that handled just above?

I think, there's a bug in the code there. The break above terminates the 
loop, yes, but then it falls through in the switch statement to the 
default case and overwrites the just found PHY.

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.

DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: +49-8142-66989-0 Fax: +49-8142-66989-80  Email: office@denx.de
