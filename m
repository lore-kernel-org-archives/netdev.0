From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP] MIB: Fine-tune reordered ACK's SACK block
 counting more
Date: Wed, 26 Sep 2007 22:01:58 -0700 (PDT)
Message-ID: <20070926.220158.25139583.davem@davemloft.net>
References: <11906246484144-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20070925.224711.26514452.davem@davemloft.net>
	<Pine.LNX.4.64.0709261653110.5141@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45211
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751842AbXI0FB7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 01:01:59 -0400
In-Reply-To: <Pine.LNX.4.64.0709261653110.5141@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 26 Sep 2007 17:07:04 +0300 (EEST)

> Hmm, thought a bit more about it... How about this then? No additiona=
l=20
> counter. Compile tested. Not that I see a large benefit from it, in t=
heory=20
> could help logging in some malicious attempt cases; we safely discard=
ed in=20
> such case anyway... ...of course if somebody is paranoid enough one m=
ight=20
> rejoice in it more than I do... :-) Buggy cases will very likely show=
 up=20
> regardless this reordering corner-case.

I don't think this is worthwile, passing extra parameters around,
etc. for not much gain.

I'll therefore not apply this one, thanks!
