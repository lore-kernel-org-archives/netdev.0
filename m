From: Ben Greear <greearb@candelatech.com>
Subject: Re: Long-term TCP connections suffer on high-latency links.
Date: Thu, 29 Jul 2004 23:25:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4109E9E0.9010208@candelatech.com>
References: <Pine.LNX.4.44.0407292206490.9625-100000@fast2.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Cheng Jin <chengjin@cs.caltech.edu>
In-Reply-To: <Pine.LNX.4.44.0407292206490.9625-100000@fast2.cs.caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cheng Jin wrote:

> As of 2.6.6 kernel, TCP Westwood, which mainly addresses issues in 
> wireless networks, BIC TCP, and TCP Vegas are all included besides TCP 
> NewReno, although not enabled by default.  The others can be downloaded 
> from the given websites.  There are probably others that I forgot to 
> mention.  Apologies to them in advance.

Any chance Westwood will get into the 2.4 kernel as well?

> Making the current TCP more ``efficient'' by increasing cwnd faster is not 
> an adequate solution, although doing that will likely produce higher 
> throughput in today's Internet.  We also must consider issues such as 
> fairness to other flows, stability of the network in terms of queue
> oscillation and packet loss, and how well these solutions would scale in 
> future networks.  A lot of experiments are still needed to determine which 
> is the most appropriate under what circumstances.

Both of the two that I read about (Highspeed TCP and FAST tcp)
did indeed increase the cwnd faster, unless I mis-understood
the papers.  Granted they do it in clever ways...

Thanks for the links.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
