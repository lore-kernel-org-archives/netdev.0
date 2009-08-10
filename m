From: Rene Mayrhofer <rene@mayrhofer.eu.org>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Mon, 10 Aug 2009 12:28:58 +0200
Message-ID: <4A7FF66A.1090506@mayrhofer.eu.org>
References: <4A65EC3F.4050400@gibraltar.at> <20090723102848.00a56ad1@nehalam>	 <4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam>	 <4A76D036.6090705@gibraltar.at> <4A772A1D.1030904@mayrhofer.eu.org>	 <4A77E56B.9030804@gibraltar.at> <392fb48f0908040445pc21105bo3182773b76d49596@mail.gmail.com> <4A78BC48.4060200@gibraltar.at> <4A78BD5F.2030901@mayrhofer.eu.org> <4A78CA13.6040409@ring3k.org> <4A7977A0.7070807@mayrhofer.eu.org> <4A7A0CBE.4020304@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.gibraltar.at ([80.120.3.98]:43856 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884AbZHJK3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 06:29:09 -0400
In-Reply-To: <4A7A0CBE.4020304@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Mike McCormack wrote:
> Rene Mayrhofer wrote:
> 
>> What would be the simplest change to stop disabling phy when the last
>> device goes down?
> 
> Commenting out the following line should stop all the phys from powering off:
> 
> sky2_phy_power_down(hw, port);
> 
> If you have a chance, please test "sky2: Add a mutex around ethtools operations" also.
> it probably won't fix the problem you're seeing, but you never know...

It seems that hardware is faulty, although in a very "interesting" way.
We tried changing the "slot" modules with 4 NICs each, which did not
change matters. However, another similar hardware appliance works. I am
thus not sure which component is at fault here, as (parts of) the NICs
were changed. Maybe the interrupt controller is weird on the "faulty"
box? ACPI issues? If anybody wants to track this any further, I am still
willing to test patches.

best regards,
Rene

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkp/9moACgkQq7SPDcPCS979XACfRD6e5ixtX3oPiQCpC78nowO4
TH4Anivuo53VZsRO9LAIDIg7zYurW8UI
=MwmU
-----END PGP SIGNATURE-----
