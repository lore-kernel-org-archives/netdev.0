From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] NF_CONNTRACK_H323 must depend on (IPV6 || IPV6=n)
Date: Sun, 28 Jan 2007 16:04:42 -0800 (PST)
Message-ID: <20070128.160442.48527586.davem@davemloft.net>
References: <20070128222136.GZ6017@stusta.de>
	<20070128.155348.39160134.davem@davemloft.net>
	<20070129000011.GB6017@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netfilter@lists.netfilter.org,
	netdev@vger.kernel.org, kaber@trash.net
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54825
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933001AbXA2AEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 19:04:43 -0500
In-Reply-To: <20070129000011.GB6017@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Mon, 29 Jan 2007 01:00:11 +0100

> On Sun, Jan 28, 2007 at 03:53:48PM -0800, David Miller wrote:
> > Adrian is this the correct way to constrain the selection between
> > "n" and "m" in this kind of situation?  I thought doing something
> > like "depends on IPV6" is sufficient to achieve that?
> 
> "depends on IPV6" would fix the bug - but it would also make 
> NF_CONNTRACK_H323 unavailable for all people without IPV6 support in 
> their kernel.

Yes, that is an issue.

I guess with some slightly ugly ifdefs we could support the
whole matrix of possibilities.  But perhaps that's undesirable
for another reason.

Patrick?
