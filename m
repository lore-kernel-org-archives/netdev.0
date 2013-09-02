From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v3] ipv6:introduce function to find route for redirect
Date: Mon, 02 Sep 2013 14:07:59 +0800
Message-ID: <52242B3F.6030402@cn.fujitsu.com>
References: <52217A8D.9010008@cn.fujitsu.com> <20130901210825.GD19455@order.stressinduktion.org> <5223FA1C.5020501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:19652 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752726Ab3IBGIl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 02:08:41 -0400
In-Reply-To: <5223FA1C.5020501@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B409=E6=9C=8802=E6=97=A5 10:38, Duan Jiong =E5=86=99=
=E9=81=93:
>>>  void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u=
32 mark)
>>
>> Maybe we should rename oif to iif now?
> Yes, that looks no ambiguity.
I'm sorry about that.

I finally think that there is no need to rename oif to iif, because
the argument oif will be assigned to fl6.flowi6_oif, and if we
rename it, others will be confused by this.

Thanks,
  Duan=20
