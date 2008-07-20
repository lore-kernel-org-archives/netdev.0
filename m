From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Free TCP/IP stack to be used
Date: Sun, 20 Jul 2008 11:57:33 +0200
Message-ID: <878wvw98tu.fsf@basil.nowhere.org>
References: <a967d7d00807191356v5dbd0397web585bae1598ee9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Keyur Chudgar" <kchudgar.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out01.alice-dsl.net ([88.44.60.11]:59825 "EHLO
	smtp-out01.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979AbYGTJ6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 05:58:19 -0400
In-Reply-To: <a967d7d00807191356v5dbd0397web585bae1598ee9@mail.gmail.com> (Keyur Chudgar's message of "Sat, 19 Jul 2008 13:56:07 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Keyur Chudgar" <kchudgar.linux@gmail.com> writes:

> Hi,
>
> I am looking for free TCP/IP stack to be used in my system.
> Can anybody suggest which one I should go for? It should be
> light weight and not like Linux TCP/IP stack. I came across
> LwIP, but I am not sure about it's performance.

FWIW In the big scheme of things (especially when you strip it down a
little bit at the CONFIG option level or perhaps use the 2.4 version)
the Linux stack is not actually that heavy in memory. In particular
many other stacks tend to use pre-allocated packet pools which can
easily use a lot more memory than the code delta even of a larger
stack. The Linux stack at least in most drivers doesn't do that and
only allocates memory on demand. There are unfortunately now a few
highend drivers who start using preallocated pools too, but these can
be still easily avoided.

-Andi

