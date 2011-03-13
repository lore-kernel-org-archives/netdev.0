From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch net-next-2.6 1/6] af_packet: use skb->skb_iif instead of orig_dev->ifindex
Date: Mon, 14 Mar 2011 07:52:37 +0800
Message-ID: <AANLkTimkUQ7JPAozRWnYgfwGu5wqeY-ikfdmWEGeUkrK@mail.gmail.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com> <1299935679-18135-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48568 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756608Ab1CMXw6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 19:52:58 -0400
Received: by fxm17 with SMTP id 17so2433051fxm.19
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2011 16:52:57 -0700 (PDT)
In-Reply-To: <1299935679-18135-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 12, 2011 at 9:14 PM, Jiri Pirko <jpirko@redhat.com> wrote:
> Since skb_iif has the desired value (ifindex of physical device actua=
lly
> received the traffic) use that instead.
>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> Reviewed-by: Changli Gao <xiaosuo@gmail.com>
> Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
> ---

This may "break" the ptype handlers in TX path, as we always assign
skb->dev to origdev there. Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
