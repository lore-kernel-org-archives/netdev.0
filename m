From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] l2tp: fix l2tp_recv_dequeue()
Date: Thu, 03 Nov 2011 07:50:27 +0100
Message-ID: <4EB239B3.6030001@gmail.com>
References: <CAKpUy7Z5KOfHbKfBp-qg+77cED=OxUAkm2P4pQacHaHKmKBQpw@mail.gmail.com> <1320186916.4728.1.camel@edumazet-laptop> <CAKpUy7ZTpXtUDXB+NCxa4QBr3qiwo7aBW9DmUY8ADqO8FgrUpw@mail.gmail.com> <1320217652.30178.1.camel@edumazet-laptop> <CAKpUy7Y794CJkAEtbsbTecbPq+KkniSTx4ftCncohzGsuJfk-w@mail.gmail.com> <4EB1C9D0.9000001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Misha Labjuk <spiked.yar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36865 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899Ab1KCGuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 02:50:32 -0400
Received: by wwi36 with SMTP id 36so1370609wwi.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 23:50:31 -0700 (PDT)
In-Reply-To: <4EB1C9D0.9000001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2011 23:53, Eric Dumazet wrote:


> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index 34b2dde..bf8d50c 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -397,6 +397,7 @@ static void l2tp_recv_dequeue(struct l2tp_session
> *session)
>  	 * expect to send up next, dequeue it and any other


Oh well, thunderbird mangled this patch, I'll repost it when I get back
my laptop (evolution instead of thundercrap) in ~one hour, if its still
on my desk at office :(

Sorry David.
