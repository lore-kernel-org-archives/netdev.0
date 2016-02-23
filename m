From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Invalid sk_policy[] access (was Re: Recent spontaneous reboots
 on multiple machines)
Date: Tue, 23 Feb 2016 14:39:13 -0500
Message-ID: <20160223193913.GB4941@oracle.com>
References: <20160107174105.GD23579@oracle.com>
 <alpine.LRH.2.20.1601072133480.29795@math.ut.ee>
 <20160107201445.GF23579@oracle.com>
 <20160108172022.GA3398@oracle.com>
 <alpine.LRH.2.20.1602051103140.5582@math.ut.ee>
 <20160214105131.GD20715@oracle.com>
 <alpine.LRH.2.20.1602150751180.29662@math.ut.ee>
 <20160222010201.GB23053@oracle.com>
 <20160223121244.GI28756@oracle.com>
 <alpine.LRH.2.20.1602232132190.30129@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sparclinux@vger.kernel.org, edumazet@google.com,
	netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.20.1602232132190.30129@math.ut.ee>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (02/23/16 21:36), Meelis Roos wrote:
> Sorry, I do not understand - what is 32-bit on V440? The kernel should 
> be 64-bit since it's sun4u.

v440#  getconf LONG_BIT
32

v440# uname -a
Linux v440 4.4.0-rc3-roos-00790-g264a4ac-dirty #200 SMP Mon Feb 22 19:06:21 PST 2016 sparc64 GNU/Linux

> However, I have not succeeded in reproducing the problem at will - git 
> checkout of another release + subsequent compile still does not trigger 
> it. But if it is the same problem, it seems to go int triple fault or 
> something similar for me to cause it reboot with no trace in the 
> console.

Maybe you're seeing something else then.

--Sowmini

