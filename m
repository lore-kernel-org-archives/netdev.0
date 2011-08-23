From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/4] net: convert core to skb paged frag APIs
Date: Tue, 23 Aug 2011 20:34:53 +0200
Message-ID: <CAHXqBFJSXB1z6sqEqLg_rc-GnYJBN7b7=mjwsGL8NTf6ga5qaQ@mail.gmail.com>
References: <1314092683.10283.21.camel@zakaz.uk.xensource.com> <1314092701-4347-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:49056 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684Ab1HWSfO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 14:35:14 -0400
Received: by qyk38 with SMTP id 38so2200596qyk.19
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 11:35:13 -0700 (PDT)
In-Reply-To: <1314092701-4347-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/8/23 Ian Campbell <ian.campbell@citrix.com>:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < =
skb_shinfo(skb)->nr_frags; i++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];

This is a rather common construct, so it might be worth it to
introduce something like for_each_skb_frag().

Best Regards,
Micha=C5=82 Miros=C5=82aw
