From: Andreas Schwab <schwab@suse.de>
Subject: Re: powerpc allmodconfig
Date: Thu, 16 Oct 2008 09:53:32 +0200
Message-ID: <je3aixvuv7.fsf@sykes.suse.de>
References: <20081015213337.a99a9595.akpm@linux-foundation.org>
	<20081015.220247.262683261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:51961 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136AbYJPHxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2008 03:53:49 -0400
In-Reply-To: <20081015.220247.262683261.davem@davemloft.net> (David Miller's
	message of "Wed, 15 Oct 2008 22:02:47 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

>> net/dccp/options.c: In function 'dccp_parse_options':
>> net/dccp/options.c:67: warning: 'value' may be used uninitialized in=
 this function
>
> Known issue, not trivial to fix, gcc is just being incredibly silly h=
ere as it
> can't see all of the control flow.

Seems to be fixed in gcc 4.3.  It actually needs a pretty complete valu=
e
tracking to get right.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4=
ED5
"And now for something completely different."
