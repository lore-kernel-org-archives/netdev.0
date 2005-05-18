From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] TSO Reloaded
Date: Tue, 17 May 2005 22:26:09 -0400
Message-ID: <46332e5aa197db91aaf012cf140282b4@psc.edu>
References: <20050504230731.12be1bc3.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v622)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050504230731.12be1bc3.davem@davemloft.net>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Though it may be moot by now, I just ran some tests of my own with this 
patch.  This was on a dual 2.4 GHz Xeon booted with a UP kernel, 
running iperf over an e1000 at a 1500 byte MTU.  I measured idle CPU by 
running a process which sits in a gettimeofday() loop.  Numbers are CPU 
utilization, all turned out +/- 1%.

No TSO:  86.6%
Old TSO: 61.0%
New TSO: 88.5%

   -John
