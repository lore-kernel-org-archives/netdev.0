From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ingress policying for realtime protocol
Date: Wed, 20 May 2015 18:53:00 -0700
Message-ID: <1432173180.4060.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150519211145.GA23134@pengutronix.de>
	 <CAHA+R7N8wFKPzOR0EshWzcaTUd+ChMW0zb0=1go4oV_gxoAyiA@mail.gmail.com>
	 <1432168240.4060.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7OJ8WUtPg7zah17DgkNFtcJznjnT0ys-qYN2c_Trm6S3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35183 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbbEUBxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 21:53:03 -0400
Received: by iesa3 with SMTP id a3so53177979ies.2
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 18:53:02 -0700 (PDT)
In-Reply-To: <CAHA+R7OJ8WUtPg7zah17DgkNFtcJznjnT0ys-qYN2c_Trm6S3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 18:47 -0700, Cong Wang wrote:
> On Wed, May 20, 2015 at 5:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Wed, 2015-05-20 at 16:46 -0700, Cong Wang wrote:
> >
> >> There is very little to do on ingress side since there is no queue at all,
> >> not to mention priority, you could try ifb to see if it fits your need.
> >
> > Note that if the need is to police traffic, ifb is not really needed :
> >
> 
> You really need to read Uwe's email before reply,
> he mentioned prio qdisc:
> 
> "I wonder
> what's missing to get ingress policying more versatile to allow for
> example a prio qdisc or if there is some conceptual problem that I don't
> see."


I did. He used the very precise word of policing, not shaping.

The fact there is a error in "policying" does not allow you to fix this
to "shaping".

It seems very clear to me that Uwe use case does not require ifb at all.

Listen Cong, could you please stop assuming that I am a jerk ?

Thanks !
