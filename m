From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 2/5] ipv6: make rt_sernum atomic and serial
 number fields ordinary ints
Date: Mon, 6 Oct 2014 10:26:33 -0700
Message-ID: <CAHA+R7OC21aFeB6UK4tyK7KnRBm1EhG+zbHN3wZKvuhP1vx0-A@mail.gmail.com>
References: <cover.1412585162.git.hannes@stressinduktion.org>
	<c98d73f367912e2fa164ffa7f6cc0c7ecbd21de1.1412585163.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, hideaki@yoshifuji.org,
	kafai@fb.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:45085 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbaJFR0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 13:26:34 -0400
Received: by mail-lb0-f175.google.com with SMTP id u10so4603106lbd.6
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 10:26:33 -0700 (PDT)
In-Reply-To: <c98d73f367912e2fa164ffa7f6cc0c7ecbd21de1.1412585163.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 6, 2014 at 1:52 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> @@ -1598,7 +1601,7 @@ static void fib6_prune_clones(struct net *net, struct fib6_node *fn)
>
>  static int fib6_update_sernum(struct rt6_info *rt, void *arg)
>  {
> -       __u32 sernum = *(__u32 *)arg;
> +       int sernum = *(__u32 *)arg;

Should be  *(int *) arg?
