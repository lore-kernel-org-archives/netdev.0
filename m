From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 03:08:27 -0800 (PST)
Message-ID: <20080117.030827.72477184.davem@davemloft.net>
References: <478F276D.8080407@iki.fi>
	<20080117.020616.136852595.davem@davemloft.net>
	<478F3539.5060903@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42708
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751180AbYAQLI2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 06:08:28 -0500
In-Reply-To: <478F3539.5060903@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Thu, 17 Jan 2008 13:00:09 +0200

> IMHO, it's a lot better then losing >50% of entries and the end
> of sequence message on big dumps. SPD and SADB are not that
> volatile; in most of the cases the dump would be as good as an
> atomic one.

I humbly disagree with you.  Interface behavior stability
is more important.

> I'm not sure if there's other major applications that we should
> be concerned about, but at least ipsec-tools racoon does not
> expect to get atomic dumps (which btw, comes originally from BSD).

Racoon was written as an addon to the BSD stack by an IPV6/IPSEC
project in Japan named KAME, it did not "come from BSD".  It was
added to BSD.

There are also other BSD based IPSEC daemons such as the one written
by the OpenBSD folks.

I don't think this is arguable at all.  We're not changing semantics
over what we've done for 4+ years and applications might depend upon.
It's for a deprecated interface, which makes any semantic changes that
much less inviting.

You can argue all you want, but it will not change the invariants in
the previous paragraph.

All of the time you've spent arguing is time not spent on adding
netlink support to the daemons that do not do so already.  And that
would be 2 steps forwards compared to the 1 step backwards your
desired change would be.

I've stated my position as well as I can at this point so
respectfully, since I have tons of other things to do, I'm stepping
out of this specific discussion for now.

Thank you.

