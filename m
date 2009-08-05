From: Rene Mayrhofer <rene@mayrhofer.eu.org>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Wed, 05 Aug 2009 14:14:24 +0200
Message-ID: <4A7977A0.7070807@mayrhofer.eu.org>
References: <4A65EC3F.4050400@gibraltar.at> <20090723102848.00a56ad1@nehalam>	 <4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam>	 <4A76D036.6090705@gibraltar.at> <4A772A1D.1030904@mayrhofer.eu.org>	 <4A77E56B.9030804@gibraltar.at> <392fb48f0908040445pc21105bo3182773b76d49596@mail.gmail.com> <4A78BC48.4060200@gibraltar.at> <4A78BD5F.2030901@mayrhofer.eu.org> <4A78CA13.6040409@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter1.gibraltar.at ([80.120.3.98]:37837 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933528AbZHEMOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 08:14:32 -0400
In-Reply-To: <4A78CA13.6040409@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Mike McCormack wrote:
>> Again, any hints would be greatly appreciated (and sorry for being
>> persistent about this annoying little bug...).
>
> Thanks for being persistent in testing :-)  Looks like you've got a 
> fairly unusual piece of hardware, as Stephen indicated.
Indeed, although I didn't think it _that_ unusual. It's just a 19" rack
appliance with 2 expansion slots for 4x LAN ports each. And those are
based around sky2.

But we have had problems before with kernel 2.4.34/.36 as well with that
hardware. They just weren't as easily reproducible but manifested
themselves in occasional malfunctions of the network devices that could
be solved by an ifdown/ifup cycle.
We still have one spare box and will try that one in case the hardware
is really flaky (which would be strange, given how reproducible it is
right now).

> Would you mind adding the phy_lock fix on top of the latest net-2.6
> git version of sky2 and testing that?
Tried it, doesn't fix the issue.

What would be the simplest change to stop disabling phy when the last
device goes down?

best regards,
Rene
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkp5d6AACgkQq7SPDcPCS95OuACggTuTHsZd7m6IqHt0mrqUZbju
G4wAoPfPGr5G05E6HdO9kcKflGaSx7f5
=78yk
-----END PGP SIGNATURE-----
