From: Florian Wiessner <ich@netz-guru.de>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover,
 performance.
Date: Wed, 14 May 2008 03:16:56 +0200
Message-ID: <482A3D88.2060105@netz-guru.de>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <20080514005223.GE27483@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080514005223.GE27483@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Jamie Lokier wrote:

> 
> Fwiw, I've been working on what started as a distributed database that
> is coming to be a filesystem too.  It has many qualities of both,
> hopefully the best ones.  I'm aiming for high LAN file performance
> similar to what you report with POHMELFS and would expect from any
> modern fs, while also supporting database style transactions and
> coherent queries, in a self-organising distributed system that handles
> LAN/WAN/Internet each at their best.  Mention of Paxos stirred me to
> reply - a relative of that is in there somewhere.  I have a long way
> to go before a release.
> 
> If anyone is working on something similar, I would be delighted to
> hear from them.
> 
> It scares me that I'm actually trying to do this.  But very exciting
> it is too.
> 
> It seems there's quite a bit of interesting work on Linux in this area
> right now, with BTRFS and CRFS too.

I am currently working on mysqlfs which is a fuse fs which can be used 
in conjunction with mysql-ndb cluster.

You can find the details here: http://sourceforge.net/projects/mysqlfs/
and a howto (in german, though) here: 
http://www.netz-guru.de/2008/04/03/mysqlfs-mit-mysql-ndb-cluster-als-verteiltes-dateisystem/

It is working quite well, but still lacks of caching which makes it slow
if your connection between the DB-servers have high latency/many hops.

I don't know BTRFS nor CRFS or POHMELFS but i will take a look at them.

Hope you'll find that usefull.


--
Florian Wiessner

