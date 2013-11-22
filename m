From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: dynamic TCP algorithms switching
Date: Fri, 22 Nov 2013 14:56:21 -0800
Message-ID: <20131122145621.344fa999@nehalam.linuxnetplumber.net>
References: <CAAVq3rnxE92PsJOChr+H52k5QfG7E=hAjsohK4Um0ZRO9TdYuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: yan cui <ccuiyyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:49269 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756256Ab3KVW4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 17:56:25 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so1915698pbc.26
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 14:56:25 -0800 (PST)
In-Reply-To: <CAAVq3rnxE92PsJOChr+H52k5QfG7E=hAjsohK4Um0ZRO9TdYuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Nov 2013 17:49:58 -0500
yan cui <ccuiyyan@gmail.com> wrote:

> Hi all:
> 
>    Currently, Linux has kinds of TCP congestion algorithms, such as
> reno, cubic, bic, hybla, ...., and each TCP congestion algorithm has
> its target networking environment. I just wonder to know is it
> possible to do dynamic TCP algorithm switching? In other words, the
> system has a combined TCP congestion algorithm (say, TCP-auto), and it
> behaves like one of the integrated TCP congestion algorithms according
> to different detected networking environment, but can switch to a
> different one. For example, TCP-auto totally uses the set of
> congestion control operations in TCP-cubic by default, but when it
> detects that the current OS uses wireless networking, it switches to
> some wireless friendly TCP congestion algorithm. Does Linux have some
> features like that, or do you (networking developers and users) care
> about it?
> 
> Best Wishes!
> 

You overestimate the advantage of one verus the other.
It is possible to control algorithm on per-socket, and per-route
but other than benchmarking there or bulk transfer for normal net
traffic Cubic works fine for all environments. 
