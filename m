From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_unix: implement socket filter
Date: Tue, 18 Jan 2011 21:19:13 +0100
Message-ID: <1295381953.3194.1.camel@edumazet-laptop>
References: <1295368755-20931-1-git-send-email-ian.molton@collabora.co.uk>
	 <1295371361.3290.15.camel@edumazet-laptop>
	 <20110118175143.3a164669@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian Molton <ian.molton@collabora.co.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	ebiederm@xmission.com, xemul@openvz.org, davidel@xmailserver.org
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110118175143.3a164669@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 18 janvier 2011 =C3=A0 17:51 +0000, Alban Crequy a =C3=A9crit =
:
> Le Tue, 18 Jan 2011 18:22:41 +0100,
> Eric Dumazet <eric.dumazet@gmail.com> a =C3=A9crit :

> > Any idea on performance cost adding sk_filter() call ?
>=20
> Ian will write a performance test and repost the patch with some stat=
s.
> I don't know about the performance cost.

Dont spend time on this, it was more a question for myself ;)

Cost should be very small, unless complex filter is used, and I have a
JIT compiler for BPF on x86_64, will post it when net-next-2.6 reopens.
