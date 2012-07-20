From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next] tcp: fix ABC in tcp_slow_start()
Date: Fri, 20 Jul 2012 11:13:34 -0700
Message-ID: <CADVnQy=2JJhRq-uQaAye3un0hHh_bYhuVam6Czez4dC8-yMAMA@mail.gmail.com>
References: <wwxik81fhb83pkj3alus6j68.1342807303829@email.android.com>
	<20120720.110234.810125972347182800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stephen.hemminger@vyatta.com, ycheng@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	therbert@google.com, shemminger@vyatta.com, johnwheffner@gmail.com,
	nanditad@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50896 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582Ab2GTSNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:13:35 -0400
Received: by yenl2 with SMTP id l2so4271735yen.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 11:13:35 -0700 (PDT)
In-Reply-To: <20120720.110234.810125972347182800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 20, 2012 at 11:02 AM, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <stephen.hemminger@vyatta.com>
> Date: Fri, 20 Jul 2012 11:01:43 -0700
>
>> TCP ABC was an experiment that failed. It solves a problem that does
>> not exist on Linux. I did the implementation mostly to prove that.
>>
>> Perhaps it abc should just be removed?
>
> This is my impression as well.

Removing ABC sounds good to me as well.

neal
