From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 1/6] af_packet: use skb->skb_iif instead of
 orig_dev->ifindex
Date: Mon, 14 Mar 2011 07:54:55 +0100
Message-ID: <20110314065454.GA2751@psychotron.redhat.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
 <1299935679-18135-2-git-send-email-jpirko@redhat.com>
 <AANLkTimkUQ7JPAozRWnYgfwGu5wqeY-ikfdmWEGeUkrK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753755Ab1CNGzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 02:55:08 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTimkUQ7JPAozRWnYgfwGu5wqeY-ikfdmWEGeUkrK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 14, 2011 at 12:52:37AM CET, xiaosuo@gmail.com wrote:
>On Sat, Mar 12, 2011 at 9:14 PM, Jiri Pirko <jpirko@redhat.com> wrote:
>> Since skb_iif has the desired value (ifindex of physical device actu=
ally
>> received the traffic) use that instead.
>>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> Reviewed-by: Changli Gao <xiaosuo@gmail.com>
>> Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
>> ---
>
>This may "break" the ptype handlers in TX path, as we always assign
>skb->dev to origdev there. Thanks.

Changli, would you please point me the relevant code?. Thanks!

Jirka
>
>--=20
>Regards,
>Changli Gao(xiaosuo@gmail.com)
