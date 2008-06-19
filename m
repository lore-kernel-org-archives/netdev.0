From: David Miller <davem@davemloft.net>
Subject: Re: Multiple TX queue implementation and Batching
Date: Thu, 19 Jun 2008 02:21:38 -0700 (PDT)
Message-ID: <20080619.022138.265296442.davem@davemloft.net>
References: <20080619.021039.193704469.davem@davemloft.net>
	<OF38F6814F.441FEEF8-ON6525746D.0032B3BA-6525746D.00331325@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39215
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754771AbYFSJVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 05:21:38 -0400
In-Reply-To: <OF38F6814F.441FEEF8-ON6525746D.0032B3BA-6525746D.00331325@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Thu, 19 Jun 2008 14:47:52 +0530

> What about core networking changes? I think you were planning to
> remove a lot of stuff (device busy checks, requeue's, etc?) and
> also implement lockless code (sch_generic.c at the very least).
> Are those ready for taking an initial look?

We can't do that completely until every driver has it's TX path
converted, which isn't likely to happen so we'll have a compat
layer for a long time.

I haven't touched one line of generic code yet.  It isn't necessary
to test out all of these ideas.
