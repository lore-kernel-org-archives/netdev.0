From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool 5/5] ethtool: Add --version option
Date: Tue, 22 Feb 2011 21:49:12 +0000
Message-ID: <1298411352.14956.23.camel@bwh-desktop>
References: <1561212236.5138.1298355384916.JavaMail.root@tahiti.vyatta.com>
	 <1298378228.2211.472.camel@localhost>
	 <1298379945.2861.7.camel@edumazet-laptop>  <4D642C14.6020505@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43936 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930Ab1BVVtP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 16:49:15 -0500
In-Reply-To: <4D642C14.6020505@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-22 at 16:35 -0500, Jeff Garzik wrote:
> On 02/22/2011 08:05 AM, Eric Dumazet wrote:
> > Le mardi 22 f=C3=A9vrier 2011 =C3=A0 12:37 +0000, Ben Hutchings a =C3=
=A9crit :
> >> On Mon, 2011-02-21 at 22:16 -0800, Stephen Hemminger wrote:
> >> [...]
> >>> The standard convention is to use -V for short form of version op=
tion.
> >>
> >> This is not anywhere near standard.
> >>
> >> $ cp -V
> >> cp: invalid option -- 'V'
> >> Try `cp --help' for more information.
> >> $ bash -V
> >> bash: -V: invalid option
> >> [...]
> >> $ emacs -V
> >> [opens window]
> >> $ vim -V
> >> chdir(/usr/share/vim)
> >> fchdir() to previous dir
> >> sourcing "$VIM/vimrc"
> >> [...looks like that meant 'verbose'...]
> >
> > Now try with networking tools, many use -V
> >
> > (As a matter of fact, ethtool -h already is used to display help)
> >
> > # ping -V
> > ping utility, iputils-sss20071127
> > # tc -V
> > tc utility, iproute2-ss100823
> > # ssh -V
> > OpenSSH_5.1p1 Debian-5, OpenSSL 0.9.8g 19 Oct 2007
>=20
> Stephen is correct, "-V" is a common standard (but by no means=20
> universal).  The following is what using argp ("info argp") generates=
=20
> for any program by default:
[...]

Well, it's my bikeshed now. :-)  I don't think it's worth using one of
the few remaining letters on this.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

