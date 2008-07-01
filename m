From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Add support for rx flow hash configuration in a
 network device
Date: Mon, 30 Jun 2008 21:42:23 -0700 (PDT)
Message-ID: <20080630.214223.53060905.davem@davemloft.net>
References: <871w2gph8r.fsf@basil.nowhere.org>
	<20080629.134936.139001500.davem@davemloft.net>
	<adaabh2ffc6.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, Santwona.Behera@Sun.COM,
	netdev@vger.kernel.org, jeff@garzik.org, Matheos.Worku@Sun.COM,
	Michael.Speer@Sun.COM, gkernel-commit@lists.sourceforge.net
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50252
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750785AbYGAEmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 00:42:23 -0400
In-Reply-To: <adaabh2ffc6.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 30 Jun 2008 20:33:45 -0700

>  > We've discussed this before and Jeff Garzik and I already told
>  > everyone that we want to make this configurable and ethtool is
>  > the way to do it no matter how adhoc and device specific the
>  > interfaces might end up being.
> 
> I think it was a few weeks ago that Jeff said:
> 
>   I know user interfaces are annoying because you have to think about 
>   chips other than your own, but that's life.  Other hardware vendors have 
>   to do it too.
> 
>   Letting each driver have a different user interface is /unfriendly/ to 
>   both developers users.
> 
> I guess as long as you stick an "ethtool" in front of the different
> interfaces it all becomes OK.

This interface we're talking about is in fact not all that device
specific, and it's extensible so that we can describe different types
of flow hashing types if so needed to support other chips.

Currently Sun's Neptune is the only one that offers so many options,
and to be honest I expect other implementations to be subsets of what
Neptune can do.
