From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] HTB updates class's bstats in one place
Date: Wed, 29 Oct 2008 10:23:56 +0000
Message-ID: <20081029102356.GA6165@ff.dom.local>
References: <49082AA5.20801@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:31875 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425AbYJ2KYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 06:24:03 -0400
Received: by ug-out-1314.google.com with SMTP id 39so550492ugf.37
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 03:24:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <49082AA5.20801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29-10-2008 10:19, Patrick McHardy wrote:
> Changli Gao wrote:
>> On Wed, Oct 29, 2008 at 5:01 PM, Patrick McHardy <kaber@trash.net> wrote:
>>> The estimators needs
>>> this since they're estimating the arrival rate.
>>>
>>>
>> I do not agree with you. TC is only for sending packets. Why does its
>> estimator estimating the arrival rate?
> 
> I suppose because they were intended for policing.

On the other hand, it seems with shaping qdiscs they are more useful
to query dequeue rates. BTW, after this patch there is still
"a statistics bug": the statistics data of a qdisc can differ from
its classes.

Jarek P.
