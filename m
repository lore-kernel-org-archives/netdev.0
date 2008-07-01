From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] UDP SndbufErrors interface and the /proc/net/udp interface.
Date: Tue, 01 Jul 2008 12:18:45 +0200
Message-ID: <87wsk5ucu2.fsf@basil.nowhere.org>
References: <d0383f90806302347q702416faxe29901bf0d2cdbbb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Ian Brown" <ianbrn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out01.alice-dsl.net ([88.44.60.11]:8323 "EHLO
	smtp-out01.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbYGAKTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 06:19:10 -0400
In-Reply-To: <d0383f90806302347q702416faxe29901bf0d2cdbbb@mail.gmail.com> (Ian Brown's message of "Tue, 1 Jul 2008 09:47:23 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Ian Brown" <ianbrn@gmail.com> writes:
>
> I wonder: would such a patch (form me or others) in needed ? Or will
> it be rejected because this idea is not good ?
> In case this idea is not good, I wonder what is the reason for it.

One possible reason against it is that struct sock size is relatively 
critical for memory consumption and there's usually some resistance
against adding more fields for it.

That might be overriden by a very clear use case.

-Andi

