From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [RFC] fib_trie: memory waste solutions
Date: Mon, 7 Apr 2008 16:42:35 +0200
Message-ID: <18426.13019.345218.79888@robur.slu.se>
References: <20080401172702.094c0700@extreme>
	<47F33D42.9080302@cosmosbay.com>
	<47F39998.8040605@cosmosbay.com>
	<20080402110335.66b04181@extreme>
	<47F3E031.1030806@cosmosbay.com>
	<20080404090257.2ec38b0c@extreme>
	<18425.50538.876583.892728@robur.slu.se>
	<87bq4mrt9v.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:47377 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755394AbYDGOmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 10:42:50 -0400
In-Reply-To: <87bq4mrt9v.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Andi Kleen writes:

 > >  Do we get slower with vmalloc due to TLB-lookups etc? Guess this
 > >  should be investigated.
 > 
 > In some cases it might even go faster because a lot of x86 CPUs
 > have far more 4K TLBs than 2M TLBs. vmalloc is just quite expensive
 > in setup/free time, but that shouldn't be a big issue here.


 I've did some rDoS testing and the lookup performance is the same or 
 slightly better. So it should be fine.  


 Cheers
					--ro

 

  
