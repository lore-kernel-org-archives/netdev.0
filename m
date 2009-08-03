From: Rene Mayrhofer <rene@mayrhofer.eu.org>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Mon, 03 Aug 2009 20:19:09 +0200
Message-ID: <4A772A1D.1030904@mayrhofer.eu.org>
References: <4A65EC3F.4050400@gibraltar.at>	<20090723102848.00a56ad1@nehalam>	<4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam> <4A76D036.6090705@gibraltar.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	mikem@ring3k.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter1.gibraltar.at ([80.120.3.98]:43370 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbZHCS3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 14:29:37 -0400
In-Reply-To: <4A76D036.6090705@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Rene Mayrhofer wrote:
> I have now tried again with the newest stable kernel (2.6.30.4), without
> PaX and squashfs-lzma support. Still the same problem:
Sorry for replying to myself, but I tried a few more things to do with MSI:

Neither
  find /sys -name "msi_bus" | while read f; do echo 0 > $f; done
nor booting with
  pci=nomsi
changed anything. The oops still happens when setting the last sky2
interface down.

> To allow easier debugging, I have now put our whole kernel tree up in a
> public (read-only) git repository at
> https://www.gibraltar.at/git/linux-2.6-gibraltar.git. The branch for
> this kernel is origin/gibraltar-3.0, although the above dump was
> produced by a version slightly "older" then HEAD, which did not yet have
> the latest PaX patch applied (no PaX and no lzma-squashfs in this kernel).
I have now updated the branch with both patches (the one from Stephen
and the other one Mike). Still trying if it changes anything with
2.6.30.4 (they didn't help with 2.6.28.10, though...).

best regards,
Rene

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkp3Kh0ACgkQq7SPDcPCS97QHgCgwdpi7RBPZNV1Of85/8qg5DsE
DWoAnjlT8U5wqN9ywxUyUpLyivH/Ex1h
=DCdB
-----END PGP SIGNATURE-----
