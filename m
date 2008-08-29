From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] export irq_set/get_affinity() for multiqueue network drivers
Date: Fri, 29 Aug 2008 10:14:22 -0700
Message-ID: <48B82E6E.2090603@hp.com>
References: <48B708E1.4070001@inria.fr> <20080829055023.07966b4a@infradead.org> <8763pjpy2b.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:23878 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754406AbYH2RO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 13:14:27 -0400
In-Reply-To: <8763pjpy2b.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Also I suspect handling SMT explicitely is a good idea. e.g. I would
> always set the affinity to all thread siblings in a core, not 
> just a single one, because context switch is very cheap between them.

That is true, but don't they also "compete" for pipeline resources?

rick jones
