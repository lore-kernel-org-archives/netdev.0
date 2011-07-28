From: Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net>
Subject: Re: r8169 driver crashes in 2.6.32.43
Date: Thu, 28 Jul 2011 23:01:12 +0200
Message-ID: <20110728210112.GA25953@colin.search.kasperd.net>
References: <20110725103643.GA11135@colin.search.kasperd.net> <20110728070455.GA11251@electric-eye.fr.zoreil.com> <20110728084821.GA24125@colin.search.kasperd.net> <20110728105831.GA11385@electric-eye.fr.zoreil.com> <20110728114305.GA24549@colin.search.kasperd.net> <20110728115936.GC24549@colin.search.kasperd.net> <20110728122328.GA11424@electric-eye.fr.zoreil.com> <20110728124548.GA24762@colin.search.kasperd.net> <20110728125437.GA24876@colin.search.kasperd.net> <20110728144719.GA11465@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ivecera@redhat.com, hayeswang@realtek.com, gregkh@suse.de,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nfitmail.nfit.au.dk ([130.225.31.129]:22627 "EHLO
	smtp.nfit.au.dk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755413Ab1G1VBT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 17:01:19 -0400
Content-Disposition: inline
In-Reply-To: <20110728144719.GA11465@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/07/11 16.47, Francois Romieu wrote:
> Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net> :
> > On 28/07/11 14.45, Kasper Dupont wrote:
> > > On 28/07/11 14.23, Francois Romieu wrote:
> > > > You can replace them with plain printk(KERN_{INFO/ERR} "S: ...)=
=2E
> > >=20
> > > Then it compiles, will let you know shortly how it works out.
> >=20
> > The last 24 lines before network stopped working:
> [...]
> > S: 000000c0
> > FEmp
> > S: 000000c0
> > FEmp
> > S: 00000040
> > S: 000000c4
> > S: 00000044
> > S: 00000040
>=20
> Can you revert the last patch and apply the one below ?

I tested it and put a picture of the output in the same place
as the error messages from before. If necessary I can try to
copy the dmesg output back over the other network interface
(assuming it is still up when the first one stops working).

>=20
> Network traffic capture at the remote end of the link would be welcom=
e,
> especially ethernet MAC control frames.

I did a dump, but it showed nothing useful. The last packet
from the machine before the network stopped was a TCP ACK.
The sending machine send three more packets before it slowed
down, then send another three packets at lower speed and then
started sending arp requests, which were not answered.

There were three separate switches on the path between the
two machines. If necessary I can try to set up a network
with just a direct link between two hosts. I am not sure
which control frames you are referring to. Will tcpdump
capture them by default?

--=20
Kasper Dupont -- Rigtige m=E6nd skriver deres egne backupprogrammer
#define _(_)"d.%.4s%."_"2s" /* This is my email address */
char*_=3D"@2kaspner"_()"%03"_("4s%.")"t\n";printf(_+11,_+6,_,11,_+2,_+7=
,_+6);
