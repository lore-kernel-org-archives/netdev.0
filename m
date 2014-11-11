From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH] net: s6gmac: remove driver
Date: Tue, 11 Nov 2014 09:32:22 +0100
Message-ID: <1415694742.16021.11.camel@x220>
References: <1413672545-8535-1-git-send-email-dg@emlix.com>
	 <20141019.124542.141206969262552652.davem@davemloft.net>
	 <CAMo8BfJ-wvDoDmm+HLHvC3VRUshdqU4eJchOGYt_YJsUktap8Q@mail.gmail.com>
	 <20141019.132801.424495087167944921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valentin Rothberg <valentinrothberg@gmail.com>, jcmvbkbc@gmail.com,
	dg@emlix.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpb-ews05.kpnxchange.com ([213.75.39.8]:60015 "EHLO
	cpsmtpb-ews05.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751705AbaKKIcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 03:32:25 -0500
In-Reply-To: <20141019.132801.424495087167944921.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-10-19 at 13:28 -0400, David Miller wrote:
> From: Max Filippov <jcmvbkbc@gmail.com>
> Date: Sun, 19 Oct 2014 21:26:05 +0400
>=20
> > On Sun, Oct 19, 2014 at 8:45 PM, David Miller <davem@davemloft.net>=
 wrote:
> >> From: Daniel Gl=C3=B6ckner <dg@emlix.com>
> >> Date: Sun, 19 Oct 2014 00:49:05 +0200
> >>
> >>> The s6000 Xtensa support is removed from the kernel. There are no
> >>> other chips using this driver.
> >>
> >> That's not what I see in Linus's current tree:
> >=20
> > David, s6000 removal is queued for 3.18.
>=20
> Then there is zero reason for me to apply this to my networking
> tree.

Commit 4006e565e150 ("xtensa: remove s6000 variant and s6105 platform")
is included in linux-next as of next-20141111. So now we see:
    $ git grep XTENSA_VARIANT_S6000 next-20141111
    next-20141111:drivers/net/ethernet/Kconfig:     depends on XTENSA_V=
ARIANT_S6000

Should Daniel resubmit, for net-next, perhaps with a commit explanation
that references this commit?


Paul Bolle
