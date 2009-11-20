From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 13:43:34 -0800
Message-ID: <1258753414.28239.66.camel@Joe-Laptop.home>
References: <4B05D8DC.7020907@gmail.com> <4B0701E2.1070806@gmail.com>
	 <4B070BAC.1090406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1070 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755130AbZKTVn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 16:43:29 -0500
In-Reply-To: <4B070BAC.1090406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-11-20 at 22:35 +0100, Eric Dumazet wrote:
> Jarek Poplawski a =C3=A9crit :
> > There is one more problem: this will break things like act_mirred +=
 ifb,
> > and other cases using skb->iif e.g. for filtering on virtual device=
s at
> > the xmit path.
> Following patch might help us to locate real uses of this obscure fie=
ld :)
> [PATCH net-next-2.6] net: rename skb->iif to skb->skb_iif

Prefixing member names generally doesn't end well.
Prefixing selected member names? ick.

