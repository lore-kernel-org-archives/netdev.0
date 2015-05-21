From: Cong Wang <cwang@twopensource.com>
Subject: Re: ingress policying for realtime protocol
Date: Wed, 20 May 2015 18:47:16 -0700
Message-ID: <CAHA+R7OJ8WUtPg7zah17DgkNFtcJznjnT0ys-qYN2c_Trm6S3A@mail.gmail.com>
References: <20150519211145.GA23134@pengutronix.de>
	<CAHA+R7N8wFKPzOR0EshWzcaTUd+ChMW0zb0=1go4oV_gxoAyiA@mail.gmail.com>
	<1432168240.4060.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>, netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:32808 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754286AbbEUBrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 21:47:17 -0400
Received: by wgjc11 with SMTP id c11so70400690wgj.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 18:47:16 -0700 (PDT)
In-Reply-To: <1432168240.4060.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 5:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-05-20 at 16:46 -0700, Cong Wang wrote:
>
>> There is very little to do on ingress side since there is no queue at all,
>> not to mention priority, you could try ifb to see if it fits your need.
>
> Note that if the need is to police traffic, ifb is not really needed :
>

You really need to read Uwe's email before reply,
he mentioned prio qdisc:

"I wonder
what's missing to get ingress policying more versatile to allow for
example a prio qdisc or if there is some conceptual problem that I don't
see."
