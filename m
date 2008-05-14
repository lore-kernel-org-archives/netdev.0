From: Jeff Garzik <jeff@garzik.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover,
 performance.
Date: Wed, 14 May 2008 17:49:35 -0400
Message-ID: <482B5E6F.4020204@garzik.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <482B2E50.2030601@garzik.org> <Pine.LNX.4.64.0805141247180.23143@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Sage Weil <sage@newdream.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0805141247180.23143@cobra.newdream.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sage Weil wrote:
> You mean if, say, some verifiable metadata or a trusted third party stores 
> that checksum?  Sure.  This is just pushing the what-has-committed 

Yes.


> information to some other party, though, who will presumably face the same 
> problem of requiring a majority for verifiable correctness.  This is more 
> or less what most people do in practice... using Paxos for critical state 
> and piggybacking the rest of the system's consistency off of that.

More like receiving a guarantee of consensus (just like any signature on 
data), while only needing to be able to communicate with a single node.


>>> (This is why Paxos is typically used only for critical cluster
>>> configuration/state, not regular data.)
>> Yep, I'm working on a config daemon a la Chubby or zookeeper, based on Paxos,
>> that does just this.  :)
> 
> Cool.  Do you have a URL?  I'd be interested in seeing how you diverge 
> from classic paxos.  For Ceph's monitor daemon, the main requirements 
> (besides strict correctness guarantees) were scalable (distributed) read 
> access, and a history of state changes.  Nothing too unusual.

Is there a URL?  Yes.  http://linux.yyz.us/projects/cld.html

It it useful?  No.  It's just a skeleton code right now.  I am 
experimenting with various Paxos algorithms as we speak, which is why 
it's fresh in my mind at the moment.

I also forgot to mention hyperspace, which is another up-and-coming 
player in this area, alongside Chubby and zookeeper.

	Jeff



