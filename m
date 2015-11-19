From: David Miller <davem@davemloft.net>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 13:09:23 -0500 (EST)
Message-ID: <20151119.130923.186891318318651425.davem@davemloft.net>
References: <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
	<1447952902.2049284.444501617.7C422D07@webmail.messagingengine.com>
	<CALx6S379hXL=QEBF-HmOvPr3K55tS87HV=wKOySro1A0ogmWcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com, lorenzo@google.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	edumazet@google.com, ek@google.com, dtor@google.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44628 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758633AbbKSSJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 13:09:29 -0500
In-Reply-To: <CALx6S379hXL=QEBF-HmOvPr3K55tS87HV=wKOySro1A0ogmWcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 19 Nov 2015 09:38:37 -0800

> 1) We need transparency. If a third party kills a TCP connection then
> the application should be informed of specifically that. This seems
> easy enough to just pick an appropriate error number as I suggested.

Agreed.

> 2) We need constraints. This feature seems to be specific to a very
> narrow use case. It is not at all clear to me if there are any
> legitimate uses cases beyond Android, enabling this by default in the
> stack creates a non-zero amount of risk and liability for abuse. It
> seems like this should be an opt-in sort of feature, with a kernel
> CONFIG or maybe opt-in per socket.

And this will probably be the point of contention.
