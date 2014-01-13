From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH net-next v4 0/3] path mtu hardening patches
Date: Mon, 13 Jan 2014 14:35:31 -0500
Message-ID: <CABrhC0n2AgHNQg-2nQk-sx1=k2=TvmGa+2seqoNT=XyDdz59yg@mail.gmail.com>
References: <1389258077-23282-1-git-send-email-hannes@stressinduktion.org>
	<20140113.112504.922587457597727366.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hannes@stressinduktion.org, Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	steffen.klassert@secunet.com, fweimer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:59109 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbaAMTfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:35:32 -0500
Received: by mail-wg0-f42.google.com with SMTP id l18so3166366wgh.1
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 11:35:31 -0800 (PST)
In-Reply-To: <20140113.112504.922587457597727366.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 2:25 PM, David Miller <davem@davemloft.net> wrote:
> From: hannes@stressinduktion.org
> Date: Thu,  9 Jan 2014 10:01:14 +0100
>
>> After a lot of back and forth I want to propose these changes regarding
>> path mtu hardening and give an outline why I think this is the best way
>> how to proceed:
>
> I'm not going to fight this any more even though I still disagree with
> these changes.  John Heffner has not provided a coherent strong
> argument for not doing this, in fact the counter arguments were
> extremely vague.
>
> I am pretty sure that now my worst fears will be realized and every
> single distribution will not use the kernel's default, and everyone
> will get this behavior rather than adminstrators making well informed
> decisions about how to defend against these kind of situations when
> enabling routing, or whether they'd even be exposed to the issue at
> all in a particular setup.
>
> Such is life.

My only comment would be not to look to me as the only source of
reason not to include this change.  I've been largely disconnected
from Linux development for several years and don't have time to get
into a protracted discussion on this topic.

FWIW, I still have doubts as to whether this is the best approach to
solving the underlying problem.  I still haven't heard any reason why
firewall rules and other administrative best practices, such as using
separate management and forwarding interfaces on a router, don't
practically solve this problem.  I'd also be curious to hear what
dedicated routing operating systems do, and why I haven't heard about
widespread fragmentation DoS attacks.

That said, this probably won't deeply break anything, but adds yet
more complexity in the core of the network stack...

  -John
