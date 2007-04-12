From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP connection stops after high load.
Date: Thu, 12 Apr 2007 14:36:34 -0700
Message-ID: <461EA662.5090801@candelatech.com>
References: <461D2DEA.4010806@candelatech.com>	<461D447C.4070408@candelatech.com>	<20070411.134804.50594117.davem@davemloft.net>	<461D4DD7.7020207@candelatech.com>	<p73y7kx7iol.fsf@bingen.suse.de>	<461E7377.3020708@candelatech.com> <20070412201940.7f570b6d.dada1@cosmosbay.com> <461E8496.2050003@candelatech.com> <461E998A.8080409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:58277 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751932AbXDLVhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 17:37:08 -0400
In-Reply-To: <461E998A.8080409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:

> Hum, could you try to bind nic irqs on separate cpus ?

I just started a run on 2.6.20.4, and so far (~20 minutes), it
is behaving perfect..running at around 925Mbps in both directions.
CWND averages about 600, bouncing from a low of 300 up to 800, but
that could very well be perfectly normal.  I'm quite pleased with
the faster performance in this kernel as well...seems like the old one
would rarely get above 800Mbps even when it was passing traffic!

I am not sure if the problem is fixed or just harder to hit,
but for now it looks good.

I'm going to also try a 2.6.19 kernel and see if the problem hits there
in an attempt to figure out what patch changed the behaviour.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

