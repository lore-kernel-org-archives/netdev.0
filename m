From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 28512] New: IPv6 SLAAC address preferred over
 static one as source address
Date: Tue, 29 Mar 2011 17:20:00 -0700 (PDT)
Message-ID: <20110329.172000.102543782.davem@davemloft.net>
References: <bug-28512-10286@https.bugzilla.kernel.org/>
	<20110207152048.22c51184.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, ghen@telenet.be
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45940
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751605Ab1C3AUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 20:20:38 -0400
In-Reply-To: <20110207152048.22c51184.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 7 Feb 2011 15:20:48 -0800

>> SLAAC addresses will have a limited preferred lifetime (as defined by the
>> router), static addresses will usually have an unlimited preferred lifetime
>> (0).  So it makes a lot of sense to take this preferred lifetime into account
>> for source address selection (how is it otherwise "preferred"?).

This is debatable.

One could just as easily say that an address with a shorter preferred
lifetime has been revalidated more recently, and therefore is more
likely to be uptodate, valid, and lead to a usable path.

I think the lack of specification for the final tie-breaker in the RFC
was intentional :-)

The specification has to address this, and until the situation is more
clear cut than it is now I don't see any benefit for changing Linux's
behavior.  Especially since there is a configuration based workaround
which works for people in the short-term.

But I'm willing to be convinced, and those wanting to convince me can
post a patch for review to netdev@vger.kernel.org :-)
