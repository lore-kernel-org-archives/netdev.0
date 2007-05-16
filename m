From: Rod Whitby <rod@whitby.id.au>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Wed, 16 May 2007 21:05:18 +0930
Message-ID: <464AEC76.7090000@whitby.id.au>
References: <464034CF.20700@wpkg.org> <20070516071300.GB14222@infradead.org> <20070516094100.GB16262@xi.wantstofly.org> <464AE10E.7090606@whitby.id.au> <20070516105626.GC16262@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Tomasz Chmielewski <mangoo@wpkg.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Michael Jones <mlj28@cam.ac.uk>,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:52851 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761015AbXEPLhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 07:37:01 -0400
In-Reply-To: <20070516105626.GC16262@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> On Wed, May 16, 2007 at 08:16:38PM +0930, Rod Whitby wrote:
>> So, if the author of these patches wishes to concentrate on big-endian
>> support first, then we will not say (and have not said) anything which
>> will block inclusion of a big-endian only version of this driver.
> 
> The NSLU2 people are the ones here that are saying that the driver
> should really support LE (because that is what they happen to be
> using, the rest of the world runs the ixp4xx in BE)

I'll repeat again.  NSLU2-Linux supports both BE and LE.  We have about
5,000 users running BE and about 5,000 users running LE.  Perhaps you're
confusing the NSLU2-Linux project (which official supports both endians
equally) with the Debian project (which official supports only LE, and
has an unofficial BE port).

One NSLU2-Linux person said they would prefer the driver to support LE,
but would be happy for it to be marked BE only in the Kconfig as an
alternative.  That is consistent with what I wrote in my message.

> Please just write the patch and let's get this over with.

Please let's just stop arguing about it.  If a patch appears before it
gets merged, then great.  If it doesn't then it will appear at a later date.

-- Rod
