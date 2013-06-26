From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2 net-next 2/2] sit: add support of x-netns
Date: Wed, 26 Jun 2013 14:15:46 +0200
Message-ID: <51CADB72.3090206@6wind.com>
References: <1372170295-4717-3-git-send-email-nicolas.dichtel@6wind.com>  <20130625.165612.1653110297729408070.davem@davemloft.net>  <87d2r964d9.fsf@xmission.com>  <20130625.224810.293452557691677283.davem@davemloft.net>  <87ppv942ad.fsf@xmission.com> <1372242136.3301.162.camel@edumazet-glaptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bcrl@kvack.org, ravi.mlists@gmail.com, bhutchings@solarflare.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:37581 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843Ab3FZMPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 08:15:50 -0400
Received: by mail-wi0-f171.google.com with SMTP id hj3so1896615wib.16
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 05:15:49 -0700 (PDT)
In-Reply-To: <1372242136.3301.162.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/06/2013 12:22, Eric Dumazet a =C3=A9crit :
> On Wed, 2013-06-26 at 03:03 -0700, Eric W. Biederman wrote:
>
>
>> That said I won't object if Nocolas Ditchel resends his patches with
>> that test put back in.  I just think it is silly and when someone
>> finally gets bit by the bug and complains we will have to go through=
 and
>> remove the test.
>
> Well, what is the reason skb_orphan() must be called in a tunnel xmit
> path ?
>
> This patch changes more things than what advertised in changelog :(
In fact, this is true. If we finally found that skb_scrub_packet() is n=
eeded in=20
all cases (not only when changing namespace), this will be another patc=
h.

I will resend the serie with the test put back.
