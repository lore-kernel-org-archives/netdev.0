From: Jeff Garzik <jeff@garzik.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover,
 performance.
Date: Wed, 14 May 2008 15:11:11 -0400
Message-ID: <482B394F.6070700@garzik.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514140908.GA14987@shareable.org> <Pine.LNX.4.64.0805140900460.23143@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Sage Weil <sage@newdream.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0805140900460.23143@cobra.newdream.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sage Weil wrote:
> On Wed, 14 May 2008, Jamie Lokier wrote:
>> In that model, neighbour sensing is used to find the largest coherency
>> domains fitting a set of parameters (such as "replicate datum X to N
>> nodes with maximum comms latency T").  If the parameters are able to
>> be met, quorum gives you the desired robustness in the event of
>> node/network failures.  During any time while the coherency parameters
>> cannot be met, the robustness reduces to the best it can do
>> temporarily, and recovers when possible later.  As a bonus, you have
>> some timing guarantees if they are more important.
> 
> Anything that silently relaxes consistency like that scares me.  Does 
> anybody really do that in practice?

Well, there's Amazon Dynamo, a distributed system that places most 
importance on writes succeeding, if inconsistent.  They choose to relax 
consistency up front, and on the backend absorb the cost of merging 
multiple versions of objects:

http://www.allthingsdistributed.com/2007/10/amazons_dynamo.html
(full paper)

	Jeff



