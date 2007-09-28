From: David Miller <davem@davemloft.net>
Subject: Re: bind and O_NONBLOCK
Date: Fri, 28 Sep 2007 15:56:39 -0700 (PDT)
Message-ID: <20070928.155639.26515647.davem@davemloft.net>
References: <46F35DD9.4000909@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alan@redhat.com
To: drepper@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55488
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755214AbXI1W4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 18:56:39 -0400
In-Reply-To: <46F35DD9.4000909@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Drepper <drepper@redhat.com>
Date: Thu, 20 Sep 2007 22:59:53 -0700

> It would be ideal if we'd have such an implementation in the next few
> months so that we, in theory, can check whether the text in the
> specification makes sense.

It seems this functionality is only relevant for really ancient
protocols such as netbeui, as Alan mentioned.

The implementation would go in those protocols, the code for
which hasn't been touched substantially for years.  It is
unclear whether those protocols are even functional at this
time. :-)

So expecting an implementation in the next few months depends
upon someone standing up and actively working on those rotting
code bases.

