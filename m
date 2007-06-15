From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6] addrconf: Fix IPv6 on tuntap tunnels
Date: Fri, 15 Jun 2007 15:14:57 -0700 (PDT)
Message-ID: <20070615.151457.98556461.davem@davemloft.net>
References: <20070614.130358.90120374.davem@davemloft.net>
	<467259DD.7030703@hartkopp.net>
	<4672F9AE.6070400@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@hartkopp.net, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	koster@debian.org.tw, socketcan@hartkopp.net,
	urs@isnogud.escape.de, florz@florz.de
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34108
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754794AbXFOWOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 18:14:39 -0400
In-Reply-To: <4672F9AE.6070400@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 15 Jun 2007 16:42:22 -0400

> No, the questions should really be:
> 
> 1.  Is IPV6 supported over this media type.
> 	yes: got to 2
> 	no:  stop
> 
> 2.  Is the device MTU >= IPV6_MIN_MTU
> 	yes: continue
> 	no:  stop
> 
> Autoconfiguration is a layer on top of IPv6.  Whether it's enabled
> or not should not dictate whether IPv6 addressed may be configured or not.

Sounds good to me, patches? :-)
