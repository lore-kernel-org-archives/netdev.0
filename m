From: Andi Kleen <andi@firstfloor.org>
Subject: Re: kmemcheck detected possible information leak to userspace?
Date: Tue, 01 Jul 2008 13:47:39 +0200
Message-ID: <87skutu8pw.fsf@basil.nowhere.org>
References: <19f34abd0807010216k11a60382xf7a27b4b27f0819@mail.gmail.com>
	<20080701102459.GB30248@2ka.mipt.ru>
	<19f34abd0807010352t264fda16g826912a857e88140@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	"Pekka Enberg" <penberg@cs.helsinki.fi>,
	"Ingo Molnar" <mingo@elte.hu>, linux-kernel@vger.kernel.org
To: "Vegard Nossum" <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:31386 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbYGALsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 07:48:42 -0400
In-Reply-To: <19f34abd0807010352t264fda16g826912a857e88140@mail.gmail.com> (Vegard Nossum's message of "Tue, 1 Jul 2008 12:52:53 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Vegard Nossum" <vegard.nossum@gmail.com> writes:

> But there is one thing I forgot: Is this memory initialized by DMA? If
> so, the warning is bogus and I will go hide in shame.

Yes it is.

[btw that was something I noted during the initial review and was then
ridiculed for]

-Andi
