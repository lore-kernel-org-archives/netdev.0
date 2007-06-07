From: David Miller <davem@davemloft.net>
Subject: Re: [Devel] Re: [PATCH] Virtual ethernet tunnel
Date: Thu, 07 Jun 2007 02:07:33 -0700 (PDT)
Message-ID: <20070607.020733.123970478.davem@davemloft.net>
References: <4666CEAA.8010903@openvz.org>
	<20070606.124758.85411179.davem@davemloft.net>
	<4667BE65.2060307@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, containers@lists.osdl.org,
	netdev@vger.kernel.org, kaber@trash.net, dev@openvz.org
To: dev@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37647
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750817AbXFGJHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 05:07:17 -0400
In-Reply-To: <4667BE65.2060307@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Korotaev <dev@sw.ru>
Date: Thu, 07 Jun 2007 12:14:29 +0400

> David Miller wrote:
> > From: Pavel Emelianov <xemul@openvz.org>
> > Date: Wed, 06 Jun 2007 19:11:38 +0400
> > 
> > 
> >>Veth stands for Virtual ETHernet. It is a simple tunnel driver
> >>that works at the link layer and looks like a pair of ethernet
> >>devices interconnected with each other.
> > 
> > 
> > I would suggest choosing a different name.
> > 
> > 'veth' is also the name of the virtualized ethernet device
> > found on IBM machines, driven by driver/net/ibmveth.[ch]
> 
> AFAICS, ibmveth.c registers ethX devices, while this driver registers
> vethX by default, so there is no much conflict IMHO.

If that's the case, veth is fine with me.
