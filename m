From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Detecting TCP loss on the receiving side?
Date: Sun, 13 Jul 2008 20:52:48 +0200
Message-ID: <87iqv9zke7.fsf@basil.nowhere.org>
References: <4876668C.8040108@limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dan =?utf-8?Q?No=C3=A9?= <dnoe@limebrokerage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out01.alice-dsl.net ([88.44.60.11]:21673 "EHLO
	smtp-out01.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbYGMSwu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 14:52:50 -0400
In-Reply-To: <4876668C.8040108@limebrokerage.com> (Dan =?utf-8?Q?No=C3=A9'?=
 =?utf-8?Q?s?= message of "Thu, 10 Jul 2008 15:44:12 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan No=C3=A9 <dnoe@limebrokerage.com> writes:

> We're trying to troubleshoot some problems and we'd like to use the
> struct tcp_info method to gain some information and attempt to detect
> TCP loss events on the receiving side of a TCP stream.=20

Receiver Loss can be diagnosed using netstat -s at least. Especially if=
 you
can rule out reordering. But only system global currently, although
that might change with containers.

-Andi
