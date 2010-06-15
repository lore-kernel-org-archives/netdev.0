From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC patch net/next] net: Hoist assigns from if?
Date: Tue, 15 Jun 2010 20:04:20 +0200
Message-ID: <1276625060.2541.166.camel@edumazet-laptop>
References: <1276580526.30434.330.camel@edumazet-laptop>
	 <20100614.225910.104075511.davem@davemloft.net>
	 <1276618932.1586.64.camel@Joe-Laptop.home>
	 <20100615.102305.28825768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57546 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280Ab0FOSEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 14:04:25 -0400
Received: by wyb40 with SMTP id 40so5052227wyb.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 11:04:23 -0700 (PDT)
In-Reply-To: <20100615.102305.28825768.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 juin 2010 =C3=A0 10:23 -0700, David Miller a =C3=A9crit :
> From: Joe Perches <joe@perches.com>
> Date: Tue, 15 Jun 2010 09:22:12 -0700
>=20
> > On Mon, 2010-06-14 at 22:59 -0700, David Miller wrote:
> >> But that to me just means that until git has a friendlier way to
> >> walk backwards through blame information for a line to skip past
> >> the cleanup crapola, we shouldn't make a lot of these kinds of
> >> changes.
> >=20
> > What do you think is missing from the gitk file viewer?
>=20
> I don't use the gitk file viewer, I use "git blame".
>=20
> Requiring a GUI to get at the information I need is unacceptable.  I
> often work remotely and use text consoles for everything, even email
> and web browsing.
>=20

Same for me, I am very old school, and use a text editor I co-wrote in
1986 ;)

I just tried gitk, but ... where is 'git blame' information ?

Ah let me see : select *one* line and ask=20
'run git gui blame on this line'.

-> Error on sterr (text console) :=20

git: 'gui' is not a git command. See 'git --help'.

Did you mean one of these?
	grep
	init
	pull
	push


Hmm ?

git --version
git version 1.7.0.4

Oh well...



