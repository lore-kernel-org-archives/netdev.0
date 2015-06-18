From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next v2] bonding: Display LACP info only to CAP_NET_ADMIN
 capable user
Date: Thu, 18 Jun 2015 10:58:48 -0700
Message-ID: <CAF2d9jiEjKmtzX4p_5dc3JPoDQ8cQZ3EwRvNXuu9gm8Ysv1Exg@mail.gmail.com>
References: <1434589182-7953-1-git-send-email-maheshb@google.com>
 <1434626256.27504.208.camel@edumazet-glaptop2.roam.corp.google.com> <20150618144133.GL588@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:33142 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbbFRR7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 13:59:09 -0400
Received: by yhpn97 with SMTP id n97so61738511yhp.0
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 10:59:08 -0700 (PDT)
In-Reply-To: <20150618144133.GL588@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> Hmm... I would rather not send these fake attributes at all ?
>
> That would be my preference as well.  Sorry if my lack of elaboration on
> on my earlier email made this confusing.
>
> If there are values that should not be visible to non-root users, then
> don't send them at all.  Do not just send NULL values.
>
OK, would change this in the next rev.

Thanks,
