From: Peter =?UTF-8?B?TsO4cmx1bmQ=?= <pch@ordbogen.com>
Subject: Re: [PATCH net-next] Fixes: 0e884c7 ipv4: L3 hash-based multipath:
 tag
Date: Tue, 6 Oct 2015 07:21:03 +0200
Message-ID: <20151006072103.46aa2266@tyr>
References: <1444083297-3454-1-git-send-email-pch@ordbogen.com>
	<5612F84E.1030709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:57293 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659AbbJFFVH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 01:21:07 -0400
In-Reply-To: <5612F84E.1030709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Oct 2015 15:23:10 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> Normally the correct comment would include something like the
> following just before the signed-off-by line.
>      Fixes: 0e884c78ee19 ("ipv4: L3 hash-based multipath")
>=20

Got it - I misunderstood the format. I'll submit a revised patch in jus=
t
a sec.

> I'm also kind of curious.  Why use 2147483648LL instead of just
> casting w as a u64 and shifting by 31?  It seems like that would be
> more readable.

I thought about it it creating the fix patch, but thought I'd better
keep the changes small. I'll use shift in the revised patch.

Best Regards
 Peter N=C3=B8rlund
