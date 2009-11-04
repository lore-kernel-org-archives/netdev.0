From: Martin Devera <martin.devera@cdi.cz>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the 	HTB_CAN_SEND
 level
Date: Wed, 04 Nov 2009 12:58:01 +0100
Message-ID: <4AF16C49.409@cdi.cz>
References: <4AEF9862.8040404@gmail.com>	 <412e6f7f0911030147k659e0079ibd1f424fef0a487f@mail.gmail.com>	 <20091103100538.GC6718@ff.dom.local>	 <412e6f7f0911030518w7a5f02a4ue8a4b6539496dd8f@mail.gmail.com>	 <20091103230035.GA2352@ami.dom.local>	 <412e6f7f0911031753m4af1467fn1b0326bdf17fe48b@mail.gmail.com>	 <20091104082808.GA6224@ff.dom.local>	 <412e6f7f0911040116q6b25b705k83e5a45464698af1@mail.gmail.com>	 <20091104104245.GB6224@ff.dom.local> <4AF15E73.30806@cdi.cz> <412e6f7f0911040330uc5ebbcekfef57854fce501f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.cdi.cz ([80.95.109.117]:58486 "EHLO luxik.cdi.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755508AbZKDL56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 06:57:58 -0500
In-Reply-To: <412e6f7f0911040330uc5ebbcekfef57854fce501f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Wed, Nov 4, 2009 at 6:58 PM, Martin Devera <martin.devera@cdi.cz> wrote:
>> Hello,
>>
>> yes you are right. If I remember correctly, I tried to charge "rate"
>> tokens up to root in early versions (which makes some sense) but problem
>> is with many interior classes stuck at extreme mbuffer value, losing
>> responsivity.
> 
> It is strange. Would you like describe it more clearly?

Ahh I'm starting to understand. You are concerned mainly with

cl->tokens += diff;     /* we moved t_c; update tokens */

am I right ?
