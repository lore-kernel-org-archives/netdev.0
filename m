From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Wed, 1 Jul 2009 10:13:33 +0000
Message-ID: <20090701101333.GB12715@ff.dom.local>
References: <20090629083315.GA4712@ff.dom.local> <4A488EB8.4070602@itcare.pl> <20090629104703.GC4712@ff.dom.local> <20090630070929.GB5589@ff.dom.local> <4A4A72B9.3030400@itcare.pl> <20090630204141.GB3026@ami.dom.local> <4A4AA03D.5090808@itcare.pl> <20090701063651.GA4876@ff.dom.local> <20090701072409.GA12592@ff.dom.local> <4A4B2FA8.3040007@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:61314 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbZGAKNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 06:13:35 -0400
Received: by fxm18 with SMTP id 18so687561fxm.37
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2009 03:13:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A4B2FA8.3040007@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 11:43:04AM +0200, Pawe=B3 Staszewski wrote:
=2E..
> Yes on on previous patches there was / no warnings / no oopses or loc=
kups
>
> But now i apply this patch and i make more testing.
> First boot with start of bgpd and - traffic is not forwarded
> So i start to search and make only some routes (static without bgpd) =
=20
> thru this host
> And all is working for this host when i make all by static routes.
>
> So i change a little my bgp configuration and make default route to o=
nly =20
> one of my iBGP peers and start bgpd process
> All is working and what is weird is number of routes in kernel table.
> Kernel is learning routes from bgpd but very slowly - really very slo=
wly.

Pawel, this is really very helpful! So, this is (probably) only about
timing, not wrong memory freeing. On the other hand this test was only
for inserts. Btw., if you didn't start the second test, you can skip
it. I have to rethink this.

Many thanks,
Jarek P.
