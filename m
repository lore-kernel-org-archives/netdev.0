From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: GRE+XFRM+GSO crashes
Date: Tue, 21 May 2013 21:56:30 -0700
Message-ID: <CALnjE+q5MN3PJiKpEiY-ZtR-i2w1rA58TQ_bAZmV8cKomg=aNQ@mail.gmail.com>
References: <20130520094127.546a2f3e@vostro>
	<CALnjE+qgOQUDm_gAuygpDE5VH23YS0i3QyQuCVPhgu15=jwXWw@mail.gmail.com>
	<20130521110132.37dc2665@vostro>
	<CALnjE+qOf2pxzP0-7s4AsSNDbG5M5s8bXFDqYoD-5NgmtKYixA@mail.gmail.com>
	<1369176375.3301.259.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:36256 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751073Ab3EVE4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 00:56:31 -0400
Received: by mail-qe0-f42.google.com with SMTP id cz11so900814qeb.15
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 21:56:30 -0700 (PDT)
In-Reply-To: <1369176375.3301.259.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 21, 2013 at 3:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-05-21 at 15:32 -0700, Pravin Shelar wrote:
>
>> OK. I am still not able to reproduce it, Can you try attached patch?
>> if that works, I will send out proper patch.
>
> strange, dev_gso_segment() doesnt change skb->cb[]
> only dev_gso_segment() does.
>
The patch is about SKB_GSO_CB not DEV_GSO_CB.

>
>
