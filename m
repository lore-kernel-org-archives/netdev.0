From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Tue, 14 Aug 2012 22:39:07 -0700 (PDT)
Message-ID: <20120814.223907.1954070712467723629.davem@davemloft.net>
References: <20120814023155.ffe9c01d.billfink@mindspring.com>
	<CAEkNxbFgr1Qws_Fp3igDhir-81R-XWr52inmuXb1MNS9NigU0Q@mail.gmail.com>
	<20120815012428.c747fa9d.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brutus@google.com, edumazet@google.com, netdev@vger.kernel.org
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006Ab2HOFjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 01:39:08 -0400
In-Reply-To: <20120815012428.c747fa9d.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Fink <billfink@mindspring.com>
Date: Wed, 15 Aug 2012 01:24:28 -0400

> I see no reason to make it obtuse rather than something more
> descriptive of its function (as opposed to how it's implemented).

I want to live in a world where things are allowed to have some
character, and some slightly amusing names.  And that's why we'll
call it TCP friends, thank you very much.

> I do have some concern that since the loopback path through the
> TCP stack won't be heavily exercised anymore, it may be more likely
> for bugs or performance degradations to creep into that code.

Are you kidding me?  Most people do not use loopback TCP, they use
TCP to a real external entity.  TCP friends only kicks in for
loopback connections.

So, like all of your other concerns, this one is meritless.
