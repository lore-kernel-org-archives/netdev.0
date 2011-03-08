From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] Phonet: fix NULL-deref in
 a8059512b120362b15424f152b2548fe8b11bd0c
Date: Tue, 08 Mar 2011 11:29:23 -0800 (PST)
Message-ID: <20110308.112923.39177383.davem@davemloft.net>
References: <201103081556.18877.remi.denis-courmont@nokia.com>
	<1299592626-18510-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48966
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755618Ab1CHT2q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 14:28:46 -0500
In-Reply-To: <1299592626-18510-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Tue,  8 Mar 2011 15:56:59 +0200

> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

You don't even read what I tell you, which makes reviewing your work
insanely frustrating.

I said:

	Reference other changes like a man, by mentioned the SHA1 ID and
	giving the commit message header line inside of ("") right
	afterwards. :-)

I didn't say to put the SHA1 reference in the subject line, it's
so messy there.  Put it in the commit message.  Do you see other
people putting commit ID references in the commit header line?

Also, I said explicitly to reference the commit like this:

	$(SHA1_ID) ("commit message header line")

so in this case it would be:

	a8059512b120362b15424f152b2548fe8b11bd0c ("Phonet: implement
	per-socket destination/peer address")

because when commits get backported that SHA1_ID might be different
in the tree it gets backported to, so you have to provide that
textual reference to the commit so that in such a case it can still
be matched up.

It also irks me that you persisted to provide the most terse possible
one-line commit message.  Have a conversation in your commit message,
this isn't for you it's for other people trying to understand your
work.

The commit message header line just gives a top-level description.
Details like the reasoning, reference to relevant commits, etc.
belong in the commit message contents.
