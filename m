From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark infrastructure
Date: Mon, 15 Feb 2010 18:21:47 +0100
Message-ID: <4B7982AB.5060409@trash.net>
References: <xfrm-mark-net-next>	 <1266160732-946-1-git-send-email-hadi@cyberus.ca>	 <1266160732-946-2-git-send-email-hadi@cyberus.ca>	 <4B796B70.2050102@trash.net> <1266253235.6776.90.camel@bigi>	 <4B797F09.5050207@trash.net> <1266254073.6776.109.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65008 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556Ab0BORVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 12:21:51 -0500
In-Reply-To: <1266254073.6776.109.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Mon, 2010-02-15 at 18:06 +0100, Patrick McHardy wrote:
> 
>> One related feature which would be nice to have is the ability
>> to use marks for xfrm tunnel routing. But I'm not sure we can
>> do this in a backwards compatible way.
> 
> I take it policy routing by mark is insufficient.

The xfrm route lookup doesn't use the packet mark.

> If you have time, can you give me an example setup description of that
> and why it would be hard to be backward-compat?

A couple of years ago I used this in a multipath setup, which
was using CONNMARK to persistently bind connections (tunnels
in this case) to a route after the first selection.

The problem with backwards compatibility is that people using
marks for multipath routing are most likely not expecting the
mark to suddenly take effect for IPsec tunnel routing.
