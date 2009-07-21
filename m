From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Tue, 21 Jul 2009 21:59:50 +0200
Message-ID: <4A661E36.7000109@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at> <20090721095853.30f4fbda@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter1.gibraltar.at ([80.120.3.98]:35505 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753712AbZGUUAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 16:00:25 -0400
In-Reply-To: <20090721095853.30f4fbda@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Stephen Hemminger wrote:
> Looks like the device is disappearing from the PCI bus when
> brought down.  Can you reproduce it with 2.6.30.2 or 2.6.31-rc3?
> 
> Try later kernels.  
This is, as mentioned in my initial email, unfortunately not an option
until later kernel support squashfs-lzma again. These embedded
appliances boot from compact flash with the root FS in squashfs.

The question probably is if newer sky2 module sources would compile and
work with 2.6.28.10. Is this expected to work?

Rene
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkpmHjIACgkQq7SPDcPCS95QPwCdHoFXzDWKJVc7ZX5pfGvGq0JB
q6AAnR633XVUQA0DlVDObSKLGvBIJ6nM
=drfT
-----END PGP SIGNATURE-----
