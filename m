From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: IP1000 gigabit nic driver
Date: Thu, 27 Apr 2006 20:56:27 +0200
Message-ID: <20060427185627.GA30871@electric-eye.fr.zoreil.com>
References: <20060427142939.GA31473@fargo>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:63156 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S964947AbWD0S7b
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 14:59:31 -0400
To: Linux-kernel <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20060427142939.GA31473@fargo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David G=C3=B3mez <david@pleyades.net> :
[...]
> Does anybody in this list know why the IP1000 driver is not
> included in the kernel ?

Afaik the driver has never been submitted for inclusion.
At least not on netdev@vger.kernel.org (hint, hint).

[...]
> The card in question is:
>=20
> Sundance Technology Inc IC Plus IP1000
>=20
> and the driver can be found in sundance web, sources=20

URL please ?

> included. I tried to contact the author but my email
> bounced.
>=20
> There's no LICENSE in the source, just copyrigth
> sentences in the .c files, so i'm not sure under
> which license it's distributed :-?.

/me goes to http://www.icplus.com.tw/driver-pp-IP1000A.html

$ unzip -c IP1000A-Linux-driver-v2.09f.zip | grep MODULE_LICENSE
    MODULE_LICENSE("GPL");

It's a bit bloaty but it does not seem too bad (not mergeable "as
is" though). Do you volunteer to test random cra^W^W carefully
engineered code on your computer to help the rework/merging process ?

--=20
Ueimor
