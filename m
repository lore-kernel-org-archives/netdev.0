From: "=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?=" <bro.devel@gmail.com>
Subject: Re: [PATCH RFC v2 net-next 2/2] tcp: Add Redundant Data Bundling
 (RDB)
Date: Mon, 23 Nov 2015 21:05:44 +0100
Message-ID: <56537198.4000809@gmail.com>
References: <1448295986-14576-1-git-send-email-bro.devel+kernel@gmail.com>
 <1448295986-14576-3-git-send-email-bro.devel+kernel@gmail.com>
 <1448300602.22599.292.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=c3=a5l_Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:34189 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbbKWUF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 15:05:57 -0500
Received: by lffu14 with SMTP id u14so118085017lff.1
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 12:05:56 -0800 (PST)
In-Reply-To: <1448300602.22599.292.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/11/15 18:43, Eric Dumazet wrote:
> On Mon, 2015-11-23 at 17:26 +0100, Bendik R=C3=B8nning Opstad wrote:
>=20
>> > +
>> > +tcp_rdb_max_skbs - INTEGER
>> > +	Enable restriction on how many previous SKBs in the output queue
>> > +	RDB may include data from. A value of 1 will restrict bundling t=
o
>> > +	only the data from the last packet that was sent.
>> > +	Default: 1
>> > +
> skb is an internal thing. I would rather not expose a sysctl with suc=
h
> name.
>=20
> Can be multi segment or not (if GSO/TSO is enabled)
>=20
> So even '1' skb can have very different content, from 1 byte to ~64 K=
B

I see your point about not exposing the internal naming. What about
tcp_rdb_max_packets?
