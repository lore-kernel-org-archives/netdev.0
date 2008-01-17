From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 11:38:13 +0200
Message-ID: <478F2205.80403@iki.fi>
References: <478F0DA5.2060401@iki.fi>	<20080117.004900.58497170.davem@davemloft.net>	<478F1DEA.5070903@iki.fi> <20080117.013107.241902256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:23090 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754080AbYAQJg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 04:36:59 -0500
Received: by fg-out-1718.google.com with SMTP id e21so609687fga.17
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 01:36:58 -0800 (PST)
In-Reply-To: <20080117.013107.241902256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo_Ter=E4s <timo.teras@iki.fi>
> Date: Thu, 17 Jan 2008 11:20:42 +0200
>=20
>> Where as the pfkey bug fix is non-intrusive and helps all
>> legacy applications still using af_key by _fixing a bug in
>> kernel_.
>=20
> It's not a bug.  You're fixing a speed issue, not a crash
> or a case where AF_KEY is providing incorrect data.
>=20
> That is what I mean when I mean "life support", we fix crashes and
> data corruption.  We don't make performance tweaks.

No. The speed issue is complitely handled in xfrm_state
and xfrm_user changes.

The af_key issue is that in big dumps you get only first X
entries. The rest of the entries are dropped because the
socket receive buffer goes full. You get data corruption:
missing entries.

- Timo

