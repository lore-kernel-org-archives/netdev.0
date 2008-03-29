From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Sat, 29 Mar 2008 23:35:35 +0000
Message-ID: <47EED247.50801@andyfurniss.entadsl.com>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain> <47A4FB81.80700@fatooh.org> <47A74FEE.6080103@trash.net>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:40327 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750784AbYC2Xem (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2008 19:34:42 -0400
In-Reply-To: <47A74FEE.6080103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:

> tc filter add dev eth0 protocol ip pref 1 parent 1: handle 1 \
>         flow hash keys dst divisor 1024
> 

I've been trying to incorporate this into my own setup but haven't got 
very far :-)

I don't even know if it's possible to attach to htb subclasses and 
expect it to work. If it is do you have an example (is this what 
baseclass is for?).

I can attach to a filter to other than parent 1:0 OK but it doesn't do 
anything.

I have also tried incorporating flow into the 1:0 filters that filter to 
the htb subclasses that have the sfqs attached to them, but can't get 
ematch to work - but then I have never been able to get ematch to work. 
I can't find any examples. All I need if this is the way to go is to 
match on mark and match on anything.

Is this possible and if so, do you have/know of any examples?

Andy.
