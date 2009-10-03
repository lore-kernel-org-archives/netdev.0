From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCPCT-1: adding a sysctl
Date: Fri, 02 Oct 2009 23:26:53 -0700 (PDT)
Message-ID: <20091002.232653.140263722.davem@davemloft.net>
References: <4AC674A4.2040900@gmail.com>
	<20091002.154808.137771153.davem@davemloft.net>
	<4AC69B89.5010604@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49989
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751525AbZJCG0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2009 02:26:34 -0400
In-Reply-To: <4AC69B89.5010604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Fri, 02 Oct 2009 20:32:09 -0400

> David Miller wrote:
>> From: William Allen Simpson <william.allen.simpson@gmail.com>
>>> Ummm, I was following the suggested practice of breaking it into
>>> smaller
>>> pieces for review.  This is just the control functions and headers.
>>> I've
>>> actually completed most of the port, and am champing at the bit.
>> We can't review the helper functions and infrastructure properly until
>> we can see how they are actually used.
>> Seeing how they are used shows us how well they are designed.
>> Otherwise asking for a is absolutely pointless as we have no context
>> in which to judge the code you're showing us.
>> 
> Thanks.  I'd hand-split my code into much smaller patches for review.
> Now, I know there are patches that are *too* small....

It's not that the patches are too small, you totally misunderstand me.

The problem is that you have to post all of the patches as a set which
can be reviewed as a unit.  The ones the use the new functions as well
as the ones that add them.

It also helps if you mention in the commit message things like
"These helper functions will be used in a subsequent change which
does ..."
