From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 2/4] net: af_unix: implement stream sendpage support
Date: Wed, 20 May 2015 11:40:01 -0700
Message-ID: <CAHA+R7N+bnm5TpiR=UhsYHy9EvPTOj55wBJ2sg9ybLBL8WJX_w@mail.gmail.com>
References: <cover.1432135413.git.hannes@stressinduktion.org>
	<06647895d82d7a5188b522c00cf28398b3410628.1432135413.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:34496 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123AbbETSkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 14:40:03 -0400
Received: by wghq2 with SMTP id q2so62167473wgh.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:40:01 -0700 (PDT)
In-Reply-To: <06647895d82d7a5188b522c00cf28398b3410628.1432135413.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 8:35 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> +static ssize_t unix_stream_sendpage(struct socket *socket, struct page *page,
> +                                   int offset, size_t size, int flags)
> +{
> +       int err;
> +       bool send_sigpipe;
> +       struct sock *sk, *other;
> +       struct sk_buff *skb, *newskb, *tail;
> +
> +       err = 0;
> +       tail = NULL;
> +       newskb = NULL;
> +       sk = socket->sk;
> +       send_sigpipe = true;


Please fold them.
