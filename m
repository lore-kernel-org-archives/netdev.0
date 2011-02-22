From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ethtool 5/5] ethtool: Add --version option
Date: Tue, 22 Feb 2011 14:05:45 +0100
Message-ID: <1298379945.2861.7.camel@edumazet-laptop>
References: <1561212236.5138.1298355384916.JavaMail.root@tahiti.vyatta.com>
	 <1298378228.2211.472.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41616 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170Ab1BVNFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 08:05:54 -0500
Received: by fxm17 with SMTP id 17so2717956fxm.19
        for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 05:05:53 -0800 (PST)
In-Reply-To: <1298378228.2211.472.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 f=C3=A9vrier 2011 =C3=A0 12:37 +0000, Ben Hutchings a =C3=A9=
crit :
> On Mon, 2011-02-21 at 22:16 -0800, Stephen Hemminger wrote:
> [...]
> > The standard convention is to use -V for short form of version opti=
on.
>=20
> This is not anywhere near standard.
>=20
> $ cp -V
> cp: invalid option -- 'V'
> Try `cp --help' for more information.
> $ bash -V
> bash: -V: invalid option
> [...]
> $ emacs -V
> [opens window]
> $ vim -V
> chdir(/usr/share/vim)
> fchdir() to previous dir
> sourcing "$VIM/vimrc"
> [...looks like that meant 'verbose'...]

Now try with networking tools, many use -V

(As a matter of fact, ethtool -h already is used to display help)

# ping -V
ping utility, iputils-sss20071127
# tc -V
tc utility, iproute2-ss100823
# ssh -V
OpenSSH_5.1p1 Debian-5, OpenSSL 0.9.8g 19 Oct 2007



