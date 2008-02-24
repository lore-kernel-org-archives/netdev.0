From: Kristof Provost <Kristof@sigsegv.be>
Subject: Re: lockdep warnings in ipv6
Date: Sun, 24 Feb 2008 13:12:34 +0000
Message-ID: <20080224131234.GA4973@nereid>
References: <Pine.LNX.4.64.0802241307310.15321@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; x-action=pgp-signed
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhineheart.priorweb.be ([213.193.229.215]:33349 "HELO
	rhineheart.priorweb.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752403AbYBXNTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 08:19:21 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802241307310.15321@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 2008-02-24 13:10:58 (+0100), Jan Engelhardt <jengelh@computergmbh.de> wrote:
> Hi,
> 
> 
> when doing IPv6 (ping6, ssh otherhost, etc.), lockdep spews a warning in 
> 2.6.25-rc2 on the target. CONFIG_..._FRAME_POINTER is off,
I think that's the same bug I ran into. It was introduced in
69cc64d8d9 and reversed in 9ff56607468. I think Linus' tree has the
reversal by now.

Kristof
 
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHwW1CUEZ9DhGwDugRAkVJAKCFxUjwfQNTtAX0Z5OquJRyNimmCgCbBgio
0voGZL/B6iaz5kSLgTbV2EY=
=CPho
-----END PGP SIGNATURE-----
