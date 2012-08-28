From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: IPv4 header extension for IPv6 translation support
Date: Tue, 28 Aug 2012 12:32:30 -0700
Message-ID: <87bohu6cdt.fsf@xmission.com>
References: <CAK617oRJypmo3025f8PZSv=Rehb3NjqyNp=bQjnRFWwaGjGXzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Vlad Maraev <maraevvb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39334 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225Ab2H1Tch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 15:32:37 -0400
In-Reply-To: <CAK617oRJypmo3025f8PZSv=Rehb3NjqyNp=bQjnRFWwaGjGXzw@mail.gmail.com>
	(Vlad Maraev's message of "Tue, 28 Aug 2012 11:59:12 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Maraev <maraevvb@gmail.com> writes:

> Hi,
> I would be happy to get some feedback on my idea that is described below.
> I need to tell that I'm a newbie in Linux kernel development but it
> would be interesting for me to estimate complexity and to implement
> this in practice.

You are going over territory that has been rather thoroughly explored
already.

You might want to make a study of the rfcs from the ietf that document
why the existing solutions were chosen.

But for a few hints.
- It is possible to implement prefix translation and avoid the need for
  huge NAT state tables.  State tables are only needed when you don't
  have enough addresses or want the benefits of connection tracking.

- Any extention to ipv4 to give it larger addresses is roughly of the
  same difficulty as implementing ipv6.  In fact it is more difficult
  because ipv6 is present in most end devices today, it is the network
  links that are the bottle-neck in rolling out ipv6.

For the best interoperatiblity the best transition strategy remains
dual-stack.  With native ipv6 connectivity and some flavor of ipv4
connectivity (native, dual-stack-lite, or 646xlate).

Eric
