From: Vimal <j.vimal@gmail.com>
Subject: Re: [PATCH] htb: improved accuracy at high rates
Date: Sat, 20 Oct 2012 09:41:35 -0700
Message-ID: <CAK3Ji110q2UDbwzYpcSaBW7AQ3t=Ts+v+bo8-n3VhzV7NBmTQw@mail.gmail.com>
References: <1350685582-65334-1-git-send-email-j.vimal@gmail.com>
 <5081E7A8.2080009@hp.com> <1350717994.13333.298.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Rick Jones <rick.jones2@hp.com>, davem@davemloft.net,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:65448 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab2JTQl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 12:41:56 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so1562395vcb.19
        for <netdev@vger.kernel.org>; Sat, 20 Oct 2012 09:41:55 -0700 (PDT)
In-Reply-To: <1350717994.13333.298.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20 October 2012 00:26, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> UFO is quite a virtual feature for the moment ;)
>
> To my knowledge only one driver uses it (neterion/s2io.c)
>
> So most probably HTB sees the fragments built by the stack before
> queueing packets to the qdisc layer.
>
> tcpdump can be used to check this.


Ah you're right.  When I checked tcpdump output earlier, I checked the
IP length which was 8000 bytes, so I presumed UFO was on.  When I
looked carefully again, the bytes on the wire were MTU sized.

Thanks for the suggestions!  I just sent the next version of the patch
against net-next, and provided a simpler example that illustrates the
inaccuracy.

-- 
Vimal
