From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 09:11:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <52305571.1031303463@[10.10.2.3]>
References: <3D78CBF6.10609@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca,
   tcw@tempest.prismnet.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <3D78CBF6.10609@us.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> No, no.  Bad Martin!  Throughput didn't drop, "Specweb compliance" 
> dropped.   Those are two very, very different things.  I've found 
> that the server can produce a lot more throughput, although it 
> doesn't have the characteristics that Specweb considers compliant.  
> Just have Troy enable mod-status and look at the throughput that 
> Apache tells you that it is giving during a run.  _That_ is real
> throughput, not number of compliant connections.

By throughput I meant number of compliant connections, not bandwidth.
It may well be latency that's going out the window, rather than
bandwidth. Yes, I should use more precise terms ...

> _And_ NAPI is for receive only, right?  Also, my compliance drop 
> occurs with the NAPI checkbox disabled.  There is something else 
> in the new driver that causes our problems.

Not sure about that - I was told once that there were transmission
completion interrupts as well? What happens to those? Or am I 
confused again ...

M.
