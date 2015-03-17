From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 94991] New: TCP bug creates additional RTO in very
 specific condition
Date: Tue, 17 Mar 2015 13:44:43 -0400 (EDT)
Message-ID: <20150317.134443.687799973483992041.davem@davemloft.net>
References: <20150317083333.65b7af40@urahara>
	<CADVnQy=HA1ZYSuOOzEZavGCZfOF5_L+ExtDoJCw7nzDCj9+M8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	matiasb@gmail.com, ycheng@google.com, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602AbbCQRot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 13:44:49 -0400
In-Reply-To: <CADVnQy=HA1ZYSuOOzEZavGCZfOF5_L+ExtDoJCw7nzDCj9+M8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue, 17 Mar 2015 12:49:49 -0400

> On Tue, Mar 17, 2015 at 11:33 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> https://bugzilla.kernel.org/show_bug.cgi?id=94991
>>             Bug ID: 94991
>>            Summary: TCP bug creates additional RTO in very specific
>>                     condition
> 
> Thanks for forwarding. I posted the following on the bug:
> 
> 2.6.32 is over 5 years old (Dec 2009). I suspect this bug is in the
> old FRTO code that Yuchung removed when he rewrote FRTO from scratch
> in 2013. Can you please test a newer version of the kernel (preferably
> 3.19 but at least 3.12 or newer) to see if this bug is still around?
> Thanks!

Stephen, if you're processing networking bugzilla entries in the
future, don't even forward 2.6.x based stuff to the list please.

Thanks.
