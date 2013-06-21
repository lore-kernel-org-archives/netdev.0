From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 5/6] alx: fix MAC address alignment problem
Date: Fri, 21 Jun 2013 10:43:32 +0200
Message-ID: <1371804212.10400.1.camel@jlt4.sipsolutions.net>
References: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net>
	 <1371766494-18979-6-git-send-email-johannes@sipsolutions.net>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B729E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:50938 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681Ab3FUInh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 04:43:37 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B729E@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-21 at 09:38 +0100, David Laight wrote:
> > In two places, parts of MAC addresses are used as u32/u16
> > values. This can cause alignment problems, use put_unaligned
> > and get_unaligned to fix this.
> 
> I suspect they are always 16bit aligned, so 16bit accesses
> would be ok - rather than using byte accesses.
> However I wouldn't know how to request this with the available
> definitions....

For at least one of them, there's no such guarantee.

johannes
