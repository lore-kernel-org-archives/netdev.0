From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Piggyback the final ACK of the three way TCP connection establishment
 with the data
Date: Thu, 22 Mar 2012 16:44:31 -0700
Message-ID: <4F6BB95F.3030200@hp.com>
References: <CAK3+h2zYLsWw44cAqJN_7vE1bqbEEsDK5oqKLpej0RLuKhk3qQ@mail.gmail.com> <1332374452.9433.15.camel@edumazet-glaptop> <CAK3+h2ydKQ15U1_2dqWsHAL_LKYm-1xbJvUbeaMJShoOCU_TsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:18762 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755001Ab2CVXod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 19:44:33 -0400
In-Reply-To: <CAK3+h2ydKQ15U1_2dqWsHAL_LKYm-1xbJvUbeaMJShoOCU_TsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I like piggybacking as much as the next guy, and pushed for a bunch of 
it in the past, but are the files being transferred really that small 
relative to the RTT that the savings of the standalone ACK of the 
SYN|ACK really buys that much?

I'm sure it does nice things for a default netperf TCP_CRR test, shaving 
one segment out of 8 or so, and maybe even more on a TCP_CC test, but 
how many sub-MSS files are transferred these days?

rick jones
