From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 5/5] ipv6: don't walk node's leaf during serial
 number update
Date: Mon, 6 Oct 2014 10:58:09 -0700
Message-ID: <CAHA+R7O2GYo6vTpm9uYPVE+jamdYRPEZo5301=NnL+Zw7vmxpg@mail.gmail.com>
References: <cover.1412585162.git.hannes@stressinduktion.org>
	<60321af8a7305bec398e62858ef53bb6605878fb.1412585163.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, hideaki@yoshifuji.org,
	kafai@fb.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:38498 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318AbaJFR6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 13:58:11 -0400
Received: by mail-la0-f42.google.com with SMTP id mk6so4912132lab.1
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 10:58:09 -0700 (PDT)
In-Reply-To: <60321af8a7305bec398e62858ef53bb6605878fb.1412585163.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 6, 2014 at 1:52 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> @@ -105,6 +106,10 @@ static int fib6_new_sernum(struct net *net)
>         return new;
>  }
>
> +enum {
> +       FIB6_NO_SERNUM_CHANGE = 0,
> +};
> +

Not sure if it worth an enum definition... seems overkill for me.
