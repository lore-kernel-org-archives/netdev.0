From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] net: add rbnode to struct sk_buff
Date: Mon, 3 Nov 2014 13:41:51 -0800
Message-ID: <CAHA+R7P9PgkitLZAZrEoFfXT290rVr4oFibPyODPWhSVitA1WA@mail.gmail.com>
References: <1415031593.14083.25.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7M0--G=znvqQwy5Qmnm5po9yApcn4LjSSv8+-5c1D7RwQ@mail.gmail.com>
	<20141103.163748.929657552226178600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Yaogong Wang <wygivan@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:37001 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbaKCVlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 16:41:52 -0500
Received: by mail-la0-f42.google.com with SMTP id gq15so10446235lab.1
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 13:41:51 -0800 (PST)
In-Reply-To: <20141103.163748.929657552226178600.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 3, 2014 at 1:37 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <cwang@twopensource.com>
> Date: Mon, 3 Nov 2014 13:34:33 -0800
>
>> No objections, but this is hacky, rbnode is larger than ->next + ->prev,
>> this means ->tstamp is always overwritten. This is why netem saves it
>> to its CB. This isn't flexible.
>
> It's the size of next+prev+tstamp.  Eric is showing exactly what is
> shared with what with the struct/union layout.

I knew, I meant saving tstamp is not flexible, or at least not pretty. :)
