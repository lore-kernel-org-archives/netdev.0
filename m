From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 16:38:29 -0400
Message-ID: <1271277509.4567.66.camel@bigi>
References: <1265568122.3688.36.camel@bigi>
	 <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	 <1265641748.3688.56.camel@bigi> <1271245986.3943.55.camel@bigi>
	 <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>  <20100414124426.6aee95c3@nehalam>
	 <1271276568.4567.59.camel@bigi>
	 <1271276855.16881.1756.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	robert@herjulf.net, David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62250 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756680Ab0DNUid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 16:38:33 -0400
Received: by gyg13 with SMTP id 13so255538gyg.19
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 13:38:32 -0700 (PDT)
In-Reply-To: <1271276855.16881.1756.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-14 at 22:27 +0200, Eric Dumazet wrote:

> Only if more than one flow is involved.
> 
> And if you have many flows, chance they will spread several queues...

Over long period of time measurement, true; but even with > 1 flows, it
is possible that one flow is more active/intense than others (rtp vs
some bulk file transfer) or more processor intensive than others(eg
ipsec vs clear text) etc. 
 
BTW: just poking at intel doc on turbo boost and it seems the max a
core can steal from others is 400Mhz; so a core can go from 2.8Ghz
to 3.2Ghz. I am sure theres a lot of interesting dynamics from this ;->
I think i will try turning this thing in my tests since i have an i7.

cheers,
jamal

