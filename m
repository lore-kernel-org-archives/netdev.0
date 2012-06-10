From: Hong zhi guo <honkiko@gmail.com>
Subject: Re: Deadlock, L2TP over IP are not working, 3.4.1
Date: Sun, 10 Jun 2012 20:14:05 +0800
Message-ID: <CAA7+ByWEZDqzZhzH0FZoapqfUrujUrxyjwp6qb1SSfWBTZ=4AA@mail.gmail.com>
References: <7ed49f446365ac625437702d92946add@visp.net.lb>
	<20120607205356.GA2491@electric-eye.fr.zoreil.com>
	<1339104606.6001.4.camel@edumazet-glaptop>
	<20120607223752.GA4475@electric-eye.fr.zoreil.com>
	<1339134438.6001.13.camel@edumazet-glaptop>
	<20120608154106.GD5024@kvack.org>
	<67d8beaf421874815145fdefc69b3366@visp.net.lb>
	<1339171495.6001.118.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34561 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238Ab2FJMOH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2012 08:14:07 -0400
In-Reply-To: <1339171495.6001.118.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there any conclusion about the problem?  Will bh_lock_sock_nested
fix the lockdep violation?

On Sat, Jun 9, 2012 at 12:04 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Fri, 2012-06-08 at 18:56 +0300, Denys Fedoryshchenko wrote:
>
>> Right now i am routing around 700Mbps over there, and noticed some
>> problem with pskb_expand_head,
>> but that's separate question i will ask, if i will not be able to so=
rt
>> it out by myself.
>>
>
> Before spending too much time on this, make sure you use a kernel
> including commit 617c8c11236 ( skb: avoid unnecessary reallocations i=
n
> __skb_cow )
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml



--=20
best regards
hong zhi guo
