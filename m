From: Janice M Girouard <janiceg@us.ibm.com>
Subject: Re: patch for common networking error messages
Date: Tue, 17 Jun 2003 15:24:20 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EEF78F4.2070604@us.ibm.com>
References: <3EEF66AA.3000509@us.ibm.com>	<3EEF6A9D.6050303@pobox.com>	<3EEF7030.6030303@us.ibm.com> <20030617.125040.58438649.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, shemminger@osdl.org, Valdis.Kletnieks@vt.edu,
   girouard@us.ibm.com, stekloff@us.ibm.com, lkessler@us.ibm.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 From David S. Miller:

And when we have 1GHZ memory busses and 10GHz cpus tomorrow,
what does this say for 1gbit and 10gbit cards?

Such schemes are fundamentally flawed.

Bottom line..   I was asking for input, and I received it.  It's valid 
to say... look at the statistics.  I really like the concept of driving 
events through netlink, but querying statistics works.  


p.s.  It's been my experience that the memory system is the main 
bottleneck when trying to support a heavy network load.  When the 10 
Gigabit card emerges, and it's here today, the memory system will be 
pressed to support it, especially if you're not using zerocopy and 
you're thinking of using more than one card.  Perhaps if RDMA is 
capabilities are added to Linux, then things might be different.

So.. when do you think RDMA will show up on Linx?
