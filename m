From: thomas yang <lampsu@gmail.com>
Subject: Re: IP header identification field is zero, why?
Date: Thu, 8 Oct 2009 17:08:40 +0800
Message-ID: <f4f837ab0910080208g143ceb1dj538680ff62e6bb37@mail.gmail.com>
References: <f4f837ab0910070704k7a193be9i285573b423b96ba2@mail.gmail.com>
	 <4ACCABE0.2070804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:38687 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756277AbZJHJJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 05:09:17 -0400
Received: by iwn8 with SMTP id 8so3295510iwn.33
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2009 02:08:41 -0700 (PDT)
In-Reply-To: <4ACCABE0.2070804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> ping sends "echo request" datagrams with DF set (Dont Fragment),
> and ID=0, this is a user program building a packet from scratch.
>
> When linux replies with a "echo reply", DF is not set and an ID is included
> in the answer, increasing at each packet.
>
> About your UDP tests, DF is automatically set, and
> I believe ID on DF frames is generated only for connected sockets.
>

The IP ID for TCP is non-zero, but for UDP is zero,  strange.

I want to make the IP ID (not always zero) for UDP packets, what should I do?
(I want to use 'IP header ID, flags, offset, protocol' to identify an
IP packets)
