From: David Miller <davem@davemloft.net>
Subject: Re: BUG: scheduling while atomic: ifconfig/0x00000002/4170
Date: Wed, 12 Sep 2007 05:34:11 -0700 (PDT)
Message-ID: <20070912.053411.21914920.davem@davemloft.net>
References: <alpine.LFD.0.999.0709060923340.26804@enigma.security.iitk.ac.in>
	<20070906082301.GB21929@gondor.apana.org.au>
	<1189091995.28781.99.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, satyam@infradead.org, flo@rfc822.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, michal.k.k.piotrowski@gmail.com,
	ipw3945-devel@lists.sourceforge.net, yi.zhu@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:37276
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S966555AbXILMkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:40:07 -0400
In-Reply-To: <1189091995.28781.99.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 06 Sep 2007 17:19:55 +0200

> 
> Oh btw. Can we stick a might_sleep() into dev_close() *before* the test
> whether the device is up? That way, we'd have seen the bug, but
> apparently nobody before Florian ever did a 'ip link set wmaster0 down'
> while the other interfaces were still open.

I've added this to net-2.6.24
