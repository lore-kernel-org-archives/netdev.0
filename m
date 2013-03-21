From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 16:20:17 -0400 (EDT)
Message-ID: <20130321.162017.605403865098695084.davem@davemloft.net>
References: <CAM8tLiMbSQZZW0NBPXGgdHRSJ8UqH+q=QaR+2KOqsf-gt6RHGg@mail.gmail.com>
	<20130321.145627.565133121162775865.davem@davemloft.net>
	<CANP3RGc1+n3Qt7k53NJtPO9njZw+WNVLKTLJq=ErYJmyb-Skcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dkravkov@gmail.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	dmitry@broadcom.com, eilong@broadcom.com, pshelar@nicira.com,
	hkchu@google.com
To: maze@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967Ab3CUUUV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 16:20:21 -0400
In-Reply-To: <CANP3RGc1+n3Qt7k53NJtPO9njZw+WNVLKTLJq=ErYJmyb-Skcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <maze@google.com>
Date: Thu, 21 Mar 2013 13:14:44 -0700

> Reverting/deleting this code is going way too far.
> Mark it experimental, but don't delete it.

I disagree, people who want to play can apply the code
to their tree.

It's as simple as that.

We have very reasonable requirements for segmentation offloads, if
they are not met, the feature isn't working correctly and therefore
isn't ready for upstream.

Now if someone can provide a fix soon, that's fine too.
