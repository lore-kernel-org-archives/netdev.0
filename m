From: Jeff Garzik <jeff@garzik.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover,
 performance.
Date: Wed, 14 May 2008 15:05:26 -0400
Message-ID: <482B37F6.3080400@garzik.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Sage Weil <sage@newdream.net>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080514143105.GB14987@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamie Lokier wrote:
> Look up "one-phase commit" or even "zero-phase commit".  (The
> terminology is cheating a bit.)  As I've understood it, all commit
> protocols have a step where each node guarantees it can commit if
> asked and node failure at that point does not invalidate the guarantee
> if the node recovers (if it can't maintain the guarantee, the node
> doesn't recover in a technical sense and a higher level protocol may
> reintegrate the node).  One/zero-phase commit extends that to
> guaranteeing a certain amounts and types of data can be written before
> it knows what the data is, so write messages within that window are
> sufficient for global commits.  Guarantees can be acquired
> asynchronously in advance of need, and can have time and other limits.
> These guarantees are no different in principle from the 1-bit
> guarantee offered by the "can you commit" phase of other commit
> protocols, so they aren't as weak as they seem.

For several common Paxos usages, you can obtain consensus guarantees 
well in advance of actually needing that guarantee, making the entire 
process quite a bit more async and parallel.

Sort of a "write ahead" for consensus.

	Jeff



