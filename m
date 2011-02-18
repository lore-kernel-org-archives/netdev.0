From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH] net: Add default_advmss() methods to blackhole dst_ops
Date: Fri, 18 Feb 2011 15:43:37 +0200
Message-ID: <AANLkTi=8FXbL+Sew8EbE4uEvVXO=gNaWsRv-0RiO0JMj@mail.gmail.com>
References: <20110218050321.10415.qmail@science.horizon.com>
	<1298010735.2642.9.camel@edumazet-laptop>
	<1298023023.2595.170.camel@edumazet-laptop>
	<AANLkTi=GRPWNWZuORx1zoJJURE-drqEoMdTuKB9LZ8Ux@mail.gmail.com>
	<1298035443.6201.51.camel@edumazet-laptop>
	<AANLkTi=O1LZzSc8=qMX=R3rJpCVL8eWr1eo6NkiZXS0m@mail.gmail.com>
	<1298036005.6201.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	George Spelvin <linux@horizon.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39761 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916Ab1BRNnk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 08:43:40 -0500
In-Reply-To: <1298036005.6201.58.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 18, 2011 at 3:33 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 18 f=E9vrier 2011 =E0 21:29 +0800, Changli Gao a =E9crit =
:
>> On Fri, Feb 18, 2011 at 9:24 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> > Le vendredi 18 f=E9vrier 2011 =E0 21:16 +0800, Changli Gao a =E9cr=
it :
>> >
>> >> I am wondering why magic number 256 is used here. Is there a spec=
ial
>> >> reason? Thanks.
>> >>
>> >
>> > It really doesnt matter. SYN message will be dropped anyway.
>> >
>> > 256 happens to be the default value
>> > of /proc/sys/net/ipv4/route/min_adv_mss

Perhaps a comment would make sense then.

thanks,
Daniel.
