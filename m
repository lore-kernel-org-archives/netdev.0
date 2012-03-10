From: Mitar <mmitar@gmail.com>
Subject: Re: Ethernet-over-UDP virtual network interface
Date: Sat, 10 Mar 2012 08:31:28 -0800
Message-ID: <CAKLmikPtvOLgzuSTF=vwfZcMD7jWWRSgWaLxnSxBsa=2RSnPVA@mail.gmail.com>
References: <CAKLmikOBPB7rTZu2EfK26=3AhOQUR8xg8n4ySUKRMFmBkC1J3g@mail.gmail.com>
	<20120304170101.GH21526@kvack.org>
	<CAKLmikOVydmSJEBWwDc=Jv4XPMi3dsS+Pn9=BP_bBePD0L7K8A@mail.gmail.com>
	<20120308161138.GB23774@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Nejc Skoberne <nejc@skoberne.net>,
	Jernej Kos <kostko@unimatrix-one.org>, gw.2012@tnode.com
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:56510 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908Ab2CJQb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 11:31:29 -0500
Received: by vcqp1 with SMTP id p1so2553094vcq.19
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2012 08:31:28 -0800 (PST)
In-Reply-To: <20120308161138.GB23774@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Thu, Mar 8, 2012 at 8:11 AM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> On Tue, Mar 06, 2012 at 12:58:44AM +0100, Mitar wrote:
>> I would like something state-less. I see L2TPv3 has support for
>
> How stateless?

Stateless in the ethernet-like manner: each incoming packet is simply
decapsulated and seen as it came over the (virtual) ethernet wire.

Of course this is because I have one implementation of our needs in my
head. Probably stateless is not necessary if everything is done
automatically. But what I am saying is that it could be even
stateless, something very very simple (and efficient). That we do not
need state/sessions (on a tunnel level, of course on the IP level of
packets send around then network kernel can (and should) keep state).
Not much CPU computation, not much memory copying, no user-space
context switching.

The idea is that we need a very simple solution, robust, no
encryption, no authentication. Just to improve the throughput on
consumer routers (today with N protocol you can easily have 15Mbit/s+
links and with fiber to tunnel them further this means that CPU is
often a bottleneck).

As I see there is no simple (both in implementation and configuration
manner) solution to this problem yet? Would it be then interesting to
develop such kernel module as I described in my initial post? Is there
any chance of it being accepted into the kernel?


Mitar
