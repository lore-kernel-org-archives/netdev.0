From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH net-next v4 0/3] path mtu hardening patches
Date: Mon, 13 Jan 2014 16:50:38 -0500
Message-ID: <CABrhC0=CfPxB7rNrA0ukfZyNLuTNSBB2srohr-Yt2b4k6oHWxg@mail.gmail.com>
References: <1389258077-23282-1-git-send-email-hannes@stressinduktion.org>
	<20140113.112504.922587457597727366.davem@davemloft.net>
	<CABrhC0n2AgHNQg-2nQk-sx1=k2=TvmGa+2seqoNT=XyDdz59yg@mail.gmail.com>
	<20140113204253.GI6586@order.stressinduktion.org>
	<CABrhC0=9ff8aLG4y4gxiGrGBBHvdcWD2pCC3wyLTveKHRySg4A@mail.gmail.com>
	<20140113212808.GJ6586@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: John Heffner <johnwheffner@gmail.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	steffen.klassert@secunet.com, fweimer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:60754 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbaAMVuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 16:50:39 -0500
Received: by mail-wg0-f47.google.com with SMTP id m15so4227136wgh.2
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 13:50:38 -0800 (PST)
In-Reply-To: <20140113212808.GJ6586@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 4:28 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Mon, Jan 13, 2014 at 04:08:22PM -0500, John Heffner wrote:
>> Would it be sufficient to allow Linux to be configured in a way that
>> matches FreeBSD's behavior?  (I believe you can do this easily with
>> stateful firewall rules now, or possibly in the ICMP processing code
>> with a sysctl switch.)  I feel this would be a much cleaner approach.
>
> Actually, this is part of this series. The hardened path mtu mode provides
> exactly that (Patch 3).
>
> But because we cannot switch this on by default, I also protected the
> forwarding path. UDP path mtu discovery has been too long available on
> Linux and, I guess, a lot of applications, especially running on routers,
> depend on that.

Perhaps I misunderstood your description of FreeBSD then.  It seems
hard for me to believe that MTU discovery for UDP is broken by default
in FreeBSD.  It was not as of a couple years ago...

The nice thing about stateful firewall rules is that they give you
fine-grained policies over which ICMP messages you want to trust, and
can filter out messages that don't match "connections" with existing
state across a wide variety of protocols (including TCP, UDP and
ICMP).

  -John
