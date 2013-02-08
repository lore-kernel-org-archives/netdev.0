From: Javier Domingo <javierdo1@gmail.com>
Subject: Re: Softirqs without captured packets
Date: Fri, 8 Feb 2013 21:02:41 +0100
Message-ID: <CALZVapnbVoZ_G_viipXwm3vZC5Qkq1zwmfnf3ydvLjdjEa_8Zg@mail.gmail.com>
References: <CALZVap=wdDnTndwa+Q+MLCufj9YpY-m+wATFiKSTX2bXX-9DVw@mail.gmail.com>
 <CALZVapktiq5norswRmjZyGXpx7mYdaTgQvJ50vO2UjsJ=pf1=w@mail.gmail.com> <20130208.145728.1110053781319882182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:63174 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932068Ab3BHUK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 15:10:57 -0500
Received: by mail-vb0-f46.google.com with SMTP id b13so2524587vby.19
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 12:10:56 -0800 (PST)
In-Reply-To: <20130208.145728.1110053781319882182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I think I misexplained,

I wanted to say net's receive softirq: net_rx_action, not softirqs in general.

Javier Domingo


2013/2/8 David Miller <davem@davemloft.net>:
> From: Javier Domingo <javierdo1@gmail.com>
> Date: Fri, 8 Feb 2013 20:54:14 +0100
>
>> Just realized I didn't put the file:
>
> Softirqs happen for TX packet reclaim, other miscelanneous networking
> device events (link status changes, hw statistic overflows, etc.),
> timers, etc.
>
> They are not exclusively triggered for receive packets.
