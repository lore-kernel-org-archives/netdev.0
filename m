From: John <da_audiophile@yahoo.com>
Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
Date: Sat, 15 Feb 2014 13:04:22 -0800 (PST)
Message-ID: <1392498262.98385.YahooMailNeo@web140003.mail.bf1.yahoo.com>
References: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com> <1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com> <20140215203015.GA4528@pd.tnic>
Reply-To: John <da_audiophile@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"mlindner@marvell.com" <mlindner@marvell.com>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Borislav Petkov <bp@alien8.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm31.bullet.mail.ne1.yahoo.com ([98.138.229.24]:37567 "EHLO
	nm31.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752691AbaBOVHL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Feb 2014 16:07:11 -0500
In-Reply-To: <20140215203015.GA4528@pd.tnic>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: Borislav Petkov <>
> Sent: Saturday, February 15, 2014 3:30 PM
> Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
>=20
> If I'd have to guess, that's trying to rcu deref that struct net_gene=
ric
> *ng in net_generic() but this is only guesswork as I don't have your
> .config.
>=20
> Anyway, adding some more people to CC.
>=20


Thanks for the reply, Boris. =A0The .config is unmodified from the Arch=
 Distro default for 3.13.3-1 which can be found here:=A0http://pastebin=
=2Ecom/LPGZ8ZqA
