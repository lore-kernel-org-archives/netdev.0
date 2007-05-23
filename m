From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: r8169: hard freezes on TX
Date: Wed, 23 May 2007 08:21:02 +0200
Message-ID: <200705230821.13479.eike-kernel@sf-tec.de>
References: <200705201520.36672.eike-kernel@sf-tec.de> <20070522202934.GA21991@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart78663948.tgxhrVO5N0";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sf-mail.de ([62.27.20.61]:41391 "EHLO mail.sf-mail.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756545AbXEWGVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 02:21:13 -0400
In-Reply-To: <20070522202934.GA21991@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart78663948.tgxhrVO5N0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

You wrote:
> Rolf Eike Beer <eike-kernel@sf-tec.de> :
> [...]
>
> > I often see freezes when I do much outgoing transfer. I have never seen
> > this happening on incoming transfers. When this happens the system locks
> > up hard, I don't see anything in the log. Since this is my laptop I have
> > trouble debugging it: there is no serial console and debugging this via
> > netconsole doesn't look like a good idea.
>
> Keyboard leds are dead afterwards I guess, right ?

I'm not absolutely sure but I can do a test later today.

> If you are experiencing bugs related to networking, I suggest to stay
> away from netconsole. It is not funny to analyze several bugs at the same
> time.

I did not expect anything coming through there, last time I tested even pin=
gs=20
were unanswered. Because of this I didn't even try netconsole.

> > When I say "much outgoing transfer" this means "several megabytes". If I
> > copy out 30 MB I almost everytime get this. I usually copy that much on=
ly
> > at home when I feed my gentoo server. That host only has a 10 MBit
> > connection. Nevertheless I've also seen that on different hosts using
> > different files on different protocols (ftp, scp, smb).
> >
> :o/
>
> So it can be reproduced with a simple ftp put of several megabytes of
> data completely cached in memory (no disk access) ?

I can put it into RAM before next test to be absolutely sure.

> > This is the output of lspci for my NIC:
> >
> > 05:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101E P=
CI
> > Express Fast Ethernet controller (rev 01)
>
> I have not seen a lot of reports for this one. Either it is perfect or
> it is barely used.
>
> [...]
>
> > Hm, is there a reason why we don't use MSI here?
>
> A request for testers was posted (netdev + lk) on 16/03/2007 which
> contained MSI code for the 8168. I did not enable it for the 8101 because
> it had only received (positive) reports from 8168 users.
>
> Afair, the RFT got no feedback.

I'll dig for it.

> > Ah, one thing is missing: I've not tested it with current kernel, latest
> > I tested was 2.6.21-rc7. But I've seen this on many previous version,
> > although I thought it became better some versions ago. I wont bet on it,
> > it might just have been luck.
>
> You can/should try:
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc2 (patch-kit)
> or:
> http://www.fr.zoreil.com/people/francois/misc/20070522-2.6.22-rc2-r8169.p=
at
>ch
>
> If you are fluent with git and you do not mind rebasing, you can try
> git://electric-eye.fr.zoreil.com/home/romieu/linux/linux-2.6-out r8169
>
> (don't do the initial clone from here, thanks)
>
> As an option, akpm includes the git branch for you in -mm.

I'll take a look, thanks.

Eike

--nextPart78663948.tgxhrVO5N0
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBGU91ZXKSJPmm5/E4RAt3uAJ9kVmFreubdq3+77mSEKNVyPpgNQgCeOMtz
h12YXYwe8U+ol5OwVRbKiKI=
=dO6Y
-----END PGP SIGNATURE-----

--nextPart78663948.tgxhrVO5N0--
