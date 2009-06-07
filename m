From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] isdn: patches for 2.6.31
Date: Sun, 07 Jun 2009 04:27:24 -0700 (PDT)
Message-ID: <20090607.042724.238501430.davem@davemloft.net>
References: <20090531-patch-00.tilman@imap.cc>
	<20090601.030434.141357758.davem@davemloft.net>
	<4A2AEFE2.2090300@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: karsten-keil@t-online.de, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39277
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753143AbZFGL1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 07:27:23 -0400
In-Reply-To: <4A2AEFE2.2090300@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sun, 07 Jun 2009 00:38:26 +0200

> On 01.06.2009 12:04, David Miller wrote:
>> First problem in the second patch.  You're doing two things
>> at once.  You're adding function documentation and also adding
>> a NULL pointer check.
> 
> No problem. I can split the patch in two if you prefer it that way.

Thanks.

>> Second problem, the NULL pointer check is gratuitous.  Document
>> that the 'm' member has to be non-NULL and leave the check out.
> 
> That would be a bad solution for two reasons:
> First, the 'm' member is private to capiutil.{c,h}. Callers are
> not supposed to access it. Therefore it shouldn't be referred to
> in the interface documentation. At best, such a mention would
> leave users of the function confused how to assure that condition.
> At worst, it might mislead them into meddling directly with the
> member, thereby producing incorrect code.
> And second, the main use of capi_cmsg2str() is for error reporting
> and debugging output. Oopsing in an error handler is particularly
> troublesome. At the same time, the risk of the 'm' member being
> unexpectedly NULL is particularly high when something has gone
> wrong already. So a safety check is advisable in this case.

Fair enough.

> PS: Any objections against the other two patches?

I don't remember it's been so many days since I looked at
this series :-(
