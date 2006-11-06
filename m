From: Paul Moore <paul.moore@hp.com>
Subject: Re: linux-2.6.19-rc4-g10b1fbdb build #114 failed
Date: Sun, 5 Nov 2006 23:10:40 -0500
Message-ID: <200611052310.40504.paul.moore@hp.com>
References: <200611051943.27210.toralf.foerster@gmx.de> <Pine.LNX.4.64.0611051621450.30121@sockpuppet.zko.hp.com> <20061105.164518.104646198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: toralf.foerster@gmx.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:50855 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S1423351AbWKFEKt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 23:10:49 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061105.164518.104646198.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 05 November 2006 7:45 pm, David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Sun, 5 Nov 2006 16:24:07 -0500 (EST)
>
> > On Sun, 5 Nov 2006, Toralf F=F6rster wrote:
> > > Hello,
> > >
> > > the build with the attached .config failed, make ends with:
> > > ...
> > >
> > > : undefined reference to `cipso_v4_sock_getattr'
> > >
> > > net/built-in.o: In function `netlbl_socket_getattr':
> >
> > Ah ha!  Why did you have to go and build a kernel without TCP/IP
> > networking ;)
> >
> > It looks like I was stupid and made NetLabel depend on CONFIG_NET a=
nd not
> > CONFIG_INET, the patch below should fix this by making NetLabel dep=
end on
> > CONFIG_INET and CONFIG_SECURITY.  Please review and apply for 2.6.1=
9.
> >
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
>
> Applied, thanks Paul.
>
> What email client are you using?  There were a bunch of spacing
> issues I had to correct in your patch before it would apply
> cleanly.  (1) lines with only spaces were changed to empty lines
> (2) Severl lines had an extra space added to the beginning.

Sorry about that, that particular mail was sent with pine (I'm at home =
right=20
now and not at my work machine), usually I use quilt to send my patches=
 out. =20
I checked it briefly in pine to make sure the tabs didn't get converted=
 into=20
spaces but I guess I didn't check well enough.

--=20
paul moore
linux security @ hp
