From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Fri, 04 Apr 2008 19:54:05 +0100
Message-ID: <47F6794D.7070302@andyfurniss.entadsl.com>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain> <47A4FB81.80700@fatooh.org> <47A74FEE.6080103@trash.net> <47EED247.50801@andyfurniss.entadsl.com> <47F22CF5.4080806@trash.net> <47F28758.1010401@andyfurniss.entadsl.com> <47F37139.9080303@andyfurniss.entadsl.com> <47F37E04.4010001@trash.net> <47F3B3C5.6000701@andyfurniss.entadsl.com> <47F6062E.9050804@andyfurniss.entadsl.com> <47F606D8.108@trash.net> <47F65EDE.3010507@andyfurniss.entadsl.com>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:50051 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757346AbYDDSwh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 14:52:37 -0400
In-Reply-To: <47F65EDE.3010507@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Furniss wrote:

> Looking at the sfq code it seems that enqueue doesn't init/zero allot 
> for a new flow unless it's the first and most of what I see fits with 
> this. 

>But rarely it doesn't look like that's all there is to it.

Actually it fits perfectly, so that is all there is to it. Dequeue 
dequeues first then checks allot so even if the allot is stuck at -20345 
or something the flow will still get 1 packet per round which is what 
I've seen. I first thought it should have moved towards 0 like it does 
when it starts too high.

Andy.

