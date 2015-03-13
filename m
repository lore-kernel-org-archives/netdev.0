From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 1/4] bonding: Handle notifications during
 work-queue processing gracefully
Date: Thu, 12 Mar 2015 18:51:18 -0700
Message-ID: <CAF2d9jggWo8Kvr3N9EAsXsEApMn-hc3hLZ+r51bR16+7quX0Ug@mail.gmail.com>
References: <1426139676-27124-1-git-send-email-maheshb@google.com>
 <1426152704.11398.149.camel@edumazet-glaptop2.roam.corp.google.com> <CAHo-Ooz4Lb3uO_TA0bK8QOrXg4nBZQeAhvpAH9Av1hqma9WS_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:45229 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbbCMBvj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 21:51:39 -0400
Received: by oifu20 with SMTP id u20so17752820oif.12
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 18:51:38 -0700 (PDT)
In-Reply-To: <CAHo-Ooz4Lb3uO_TA0bK8QOrXg4nBZQeAhvpAH9Av1hqma9WS_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 11:34 AM, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> bond_get_notif_pending(struct bonding *bond,
>                                          bond_notif_pending_t bit)
> {
>        return !!test_bit(bit, &bond->notif_work_mask);
> }
>
> imho this should use test_and_clear_bit, and you should actually neve=
r
> use the pending_clear, only have pending_set

Yes good idea, will do that.
