From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 17:05:11 -0400 (EDT)
Message-ID: <20130321.170511.612698812448620739.davem@davemloft.net>
References: <CANP3RGc1+n3Qt7k53NJtPO9njZw+WNVLKTLJq=ErYJmyb-Skcg@mail.gmail.com>
	<20130321.162017.605403865098695084.davem@davemloft.net>
	<CANP3RGdjmgm10rH4AZAVt8Zx+MjwKkzxZ6hoJYuYmQXEz25qQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dkravkov@gmail.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	dmitry@broadcom.com, eilong@broadcom.com, pshelar@nicira.com,
	hkchu@google.com
To: maze@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220Ab3CUVFZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 17:05:25 -0400
In-Reply-To: <CANP3RGdjmgm10rH4AZAVt8Zx+MjwKkzxZ6hoJYuYmQXEz25qQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <maze@google.com>
Date: Thu, 21 Mar 2013 13:47:07 -0700

> They might create non incrementing IP ID packet sequences on the wire=
,
> and this may prevent GRO from kicking in, but it does not make TSO
> non-reversible
> (if anything it makes it easy to detect that it happened).

This is not an acceptable outcome for any form GSO, it should be
completely transparent.  The packets we would have output individually
and those which result from the segmented frame must be
indistinguishable.
