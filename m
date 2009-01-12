From: Valdis.Kletnieks@vt.edu
Subject: Re: RFC: Network privilege separation.
Date: Mon, 12 Jan 2009 13:44:10 -0500
Message-ID: <12821.1231785850@turing-police.cc.vt.edu>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <87mye2yg8a.fsf@basil.nowhere.org> <20090108023111.GJ3164@didacte.laptop.org>
            <20090108104305.7b271053@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1231785850_3124P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Michael Stone <michael@laptop.org>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:38149 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbZALSoW (ORCPT
	<RFC822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 13:44:22 -0500
In-Reply-To: Your message of "Thu, 08 Jan 2009 10:43:05 GMT."
             <20090108104305.7b271053@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1231785850_3124P
Content-Type: text/plain; charset=us-ascii

On Thu, 08 Jan 2009 10:43:05 GMT, Alan Cox said:

> If you have the same uid then you can just use ptrace to drive another
> task with that uid to do the creations for you. Chances are you can also
> attack shared executable files (eg that uids .bashrc)
> 
> That to me says controlling network access is only useful as part of a
> more fine grained and general purpose interface. We already have that
> interface in the form of things like SELinux. We already have systems
> actively using it to control stuff like which ports are accessed by some
> services.

Yes, the network access part *is* something that should be part of a more
general interface.  Having said that, we currently are lacking a way for a
*general user* program to say "I'm all set up, and would like to disavow any
other further resource access (except maybe r/o access as "other" to file
systems)".

It's pretty easy for stuff running as root to play setuid()/capability() games
to throw away access rights.  It's damned hard for mortal users to do it.



--==_Exmh_1231785850_3124P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJa496cC3lWbTT17ARAoYqAKCPubCGMYUvOuZpTToyRgK5O+wOXgCeP+Sj
UYiFyaDZ0OZepAsnHznWBgU=
=iU3o
-----END PGP SIGNATURE-----

--==_Exmh_1231785850_3124P--
