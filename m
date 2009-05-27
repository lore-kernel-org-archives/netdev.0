From: David Miller <davem@davemloft.net>
Subject: Re: [iproute2 patch]: Add 'ip tuntap' facility for managing
 tun/tap devices
Date: Wed, 27 May 2009 13:43:31 -0700 (PDT)
Message-ID: <20090527.134331.149161719.davem@davemloft.net>
References: <1243441938.18507.30.camel@macbook.infradead.org>
	<20090527093815.4ddf99de@nehalam>
	<1243442972.18507.32.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35649
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756142AbZE0Unc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 16:43:32 -0400
In-Reply-To: <1243442972.18507.32.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 27 May 2009 17:49:32 +0100

> On Wed, 2009-05-27 at 09:38 -0700, Stephen Hemminger wrote:
>> Almost all of iproute2 is based on netlink, I don't want to add non netlink
>> interfaces. 
> 
> So you want to add a new interface to the kernel which duplicates the
> one we've had for years, then make userspace which will only work with
> newer kernels?

I agree, Stephen just put in the ioctl() or whatever based support
for TUN devices.  We've done stuff like this before in iproute2
so your arguments against this are hogwash.
