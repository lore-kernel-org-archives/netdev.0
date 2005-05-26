From: "David S. Miller" <davem@davemloft.net>
Subject: Re: LC-trie FIB major rework
Date: Thu, 26 May 2005 13:38:15 -0700 (PDT)
Message-ID: <20050526.133815.62342715.davem@davemloft.net>
References: <17045.56331.653873.256686@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se
In-Reply-To: <17045.56331.653873.256686@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Thu, 26 May 2005 16:24:11 +0200

> Below much reworked version of the LC-trie for FIB lookup's. Much closer
> to current FIB anatomy and locking. Parent pointers in the trie to avoid 
> own stacks etc. The option to merge tables has been removed and much things 
> to keep things as simple and clean as possible. Although it's somewhat 
> complex. 
>  
> Performance. We now perform about 25-30% better than current FIB in 
> heavy lookup situations (we test with full rDoS) The test below illustrates
> this 123 kroutes in the routing table and rDoS is injected into eth0 at 
> 720 kpps routed traffic on eth1/eth3. route hash is not used and both 
> dst and src are looked up. LC-trie should work fine any size of routing table..

Very nice work Robert.  Once TSO becomes less of a time sink I
intend to help you out a bit.
