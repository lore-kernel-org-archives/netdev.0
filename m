From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 16:22:48 -0400
Message-ID: <1271276568.4567.59.camel@bigi>
References: <1265568122.3688.36.camel@bigi>
	 <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	 <1265641748.3688.56.camel@bigi> <1271245986.3943.55.camel@bigi>
	 <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>  <20100414124426.6aee95c3@nehalam>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	robert@herjulf.net, David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:36859 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582Ab0DNUWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 16:22:51 -0400
Received: by pva18 with SMTP id 18so387624pva.19
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 13:22:51 -0700 (PDT)
In-Reply-To: <20100414124426.6aee95c3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-14 at 12:44 -0700, Stephen Hemminger wrote:

> RPS might also interact with the core turbo boost functionality on Intel chips.
> Newer chips will make a single core faster if other core can be kept idle.

how well does it work with Linux? Sounds like all i need to do is turn
on some BIOS feature. 
One of the negatives with multiqueue nics is because the core selection
is static, you could end up overloading one core while others stay idle.
This seems to steal cycle capacity from the idle cores and gives it to
the busy cpus. nice. So i see it as a boost to multiqueue.

cheers,
jamal

