From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Wed, 05 Aug 2009 00:55:04 +0200
Message-ID: <4A78BC48.4060200@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at> <20090723102848.00a56ad1@nehalam>	 <4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam>	 <4A76D036.6090705@gibraltar.at> <4A772A1D.1030904@mayrhofer.eu.org>	 <4A77E56B.9030804@gibraltar.at> <392fb48f0908040445pc21105bo3182773b76d49596@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter1.gibraltar.at ([80.120.3.98]:49394 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933363AbZHDWzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 18:55:15 -0400
In-Reply-To: <392fb48f0908040445pc21105bo3182773b76d49596@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Mike McCormack wrote:
> 2009/8/4 Rene Mayrhofer <rene.mayrhofer@gibraltar.at>:
> 
>> Does anybody have an idea on what might be wrong in sky2_down?
> 
> btw. for 2.6.30, I found I could copy sky2.c from the netdev git into
> my 2.6.30 tree if I added the following line at the end of
> sky2_xmit_frame() :
> 
>         dev->trans_start = jiffies;     /* prevent tx timeout */

This seems to be already included in the current netdev git.

Nonetheless, the current unmodified version from netdev git solves the
oops in sky2. I have not diffed my old vs. this version, but whoever is
interested in which change fixed the oops, it should be somewhere in
commit 0a1449c in our Gibraltar kernel git repository.

Thanks a lot for that hint!
Rene
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkp4vEQACgkQq7SPDcPCS97BtgCfZy1QTeQOL340hD0HIgTC1c3O
Gy0An1u8zdh4wyU4DchLfxNWzqlJExV+
=0+E4
-----END PGP SIGNATURE-----
