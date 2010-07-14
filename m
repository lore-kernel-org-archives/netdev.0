From: David Miller <davem@davemloft.net>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Wed, 14 Jul 2010 14:55:47 -0700 (PDT)
Message-ID: <20100714.145547.102555471.davem@davemloft.net>
References: <4C3E0684.5060409@wildgooses.com>
	<4C3E1B54.40604@hp.com>
	<20100714203919.GD6682@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, lists@wildgooses.com, davidsen@tmr.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59716
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751404Ab0GNVzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 17:55:32 -0400
In-Reply-To: <20100714203919.GD6682@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Wed, 14 Jul 2010 22:39:19 +0200

> * Rick Jones | 2010-07-14 13:17:24 [-0700]:
> 
>>There is an effort under way, lead by some folks at Google and
>>including some others, to get the RFC's enhanced in support of the
>>concept of larger initial congestion windows.  Some of the discussion
>>may be in the "tcpm" mailing list (assuming I've not gotten my
>>mailing lists confused).  There may be some previous discussion of
>>that work in the netdev archives as well.
> 
> tcpm is the right mailing list but there is currently no effort to develop
> this topic. Why? Because is not a standardization issue, rather it is a
> technical issue. You cannot rise the initial CWND and expect a fair behavior.
> This was discussed several times and is documented in several documents and
> RFCs.
> 
> RFC 5681 Section 3.1. Google employees should start with Section 3. This topic
> pop's of every two months in netdev and until now I _never_ read a
> consolidated contribution.
> 
> Partial local issues can already be "fixed" via route specific ip options -
> see initcwnd.

Although section 3 of RFC 5681 is a great text, it does not say at all
that increasing the initial CWND would lead to fairness issues.

To be honest, I think google's proposal holds a lot of weight.  If
over time link sizes and speeds are increasing (they are) then nudging
the initial CWND every so often is a legitimate proposal.  Were
someone to claim that utilization is lower than it could be because of
the currenttly specified initial CWND, I would have no problem
believing them.

And I'm happy to make Linux use an increased value once it has
traction in the standardization community.

But for all we know this side discussion about initial CWND settings
could have nothing to do with the issue being reported at the start of
this thread. :-)

