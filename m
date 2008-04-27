From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] [IPV4]: Update MTU to all related cache entries in ip_rt_frag_needed()
Date: Sun, 27 Apr 2008 11:35:42 +0300
Message-ID: <48143ADE.40304@iki.fi>
References: <48105B67.7060804@iki.fi> <20080426.232756.259679168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:43893 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbYD0IfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 04:35:16 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1699990nfb.21
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2008 01:35:14 -0700 (PDT)
In-Reply-To: <20080426.232756.259679168.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo_Ter=E4s <timo.teras@iki.fi>
> Date: Thu, 24 Apr 2008 13:05:27 +0300
>=20
>> Add struct net_device parameter to ip_rt_frag_needed() and update MT=
U to
>> cache entries where ifindex is specified. This is similar to what is
>> already done in ip_rt_redirect().
>>
>> Signed-off-by: Timo Teras <timo.teras@iki.fi>
>=20
> I haven't forgotten about this patch, I'm just still thinking about
> possible negative side effects.  I don't think there are any, but
> I want to be sure.
>=20
> This function has been a constant source of consternation.  It also
> doesn't do the right thing when the TOS is modified mid-network, and
> that's arguably wrong too but more difficult to solve efficiently tha=
n
> this ifindex keying case.

I understand your concern. It is pretty easy break routing cache with
some seemingly unrelated changes. I tried to think about possible side
effects, but concluded that this should be safe. Then again, I don't
know all the tiny details and unusual scenarios. But I have been runnin=
g
a 2.6.23 kernel with (backported) patch on a production machine (router
connected to two ISPs, internal subnet and also having multiple gre
tunnels), so far I have not encountered any problems.

Cheers,
  Timo
