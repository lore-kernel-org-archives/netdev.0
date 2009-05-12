From: Dan McDonald <danmcd@sun.com>
Subject: Re: [danmcd@sun.com: [Ipsec-tools-devel] SHA-2 and RFC 4868]
Date: Tue, 12 May 2009 10:07:25 -0400
Message-ID: <20090512140725.GA17920@kebe.East.Sun.COM>
References: <20090508180811.GA15999@kebe.East.Sun.COM> <4A09305B.5040304@swiss-it.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Adrian-Ken R?egsegger <rueegsegger@swiss-it.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-ea-mail-3.Sun.COM ([192.18.43.21]:41994 "EHLO
	sca-ea-mail-3.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbZELOWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 10:22:31 -0400
Received: from dm-east-01.east.sun.com ([129.148.9.192])
	by sca-ea-mail-3.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n4CEMV2Z020915
	for <netdev@vger.kernel.org>; Tue, 12 May 2009 14:22:31 GMT
Received: from kebe.East.Sun.COM (kebe.East.Sun.COM [129.148.174.48])
	by dm-east-01.east.sun.com (8.13.8+Sun/8.13.8/ENSMAIL,v2.2) with ESMTP id n4CEMUUS012387
	for <netdev@vger.kernel.org>; Tue, 12 May 2009 10:22:30 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <4A09305B.5040304@swiss-it.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2009 at 10:16:27AM +0200, Adrian-Ken R?egsegger wrote:

<mucho snippage deleted!>

> > Is this just me, or is there an unfixed kernel problem in other platforms'
> > AH/ESP code?
> 
> This issues was discussed (but not resolved) a bit less than a year ago:
> 
> http://lkml.org/lkml/2008/6/5/141

Thanks for the thread pointer.  I would like it if you guys updated to RFC
4868, but I'm obviously in no position to have any influence.  If you wanna
test it, though, OpenSolaris has 4868 support, and if you need help for
interoperability testing, just ask.

BTW, it *is* possible to have user-space supply such parameters.  Have a look
at the ipsecalgs(1M) man page for an example:

http://docs.sun.com/app/docs/doc/816-5166/ipsecalgs-1m?l=en&a=view&q=ipsecalgs

In fact, we've done backward compatibility tests with MacOS X by adjusting
the truncation size with ipsecalgs(1M).  ISTR it worked with SHA-256.

Dan
