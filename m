From: Baruch Even <baruch@ev-en.org>
Subject: Re: Long-term TCP connections suffer on high-latency links.
Date: Fri, 30 Jul 2004 10:34:53 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730073453.GA14412@ev-en.org>
References: <Pine.LNX.4.44.0407292206490.9625-100000@fast2.cs.caltech.edu> <4109E9E0.9010208@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cheng Jin <chengjin@cs.caltech.edu>,
        "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <4109E9E0.9010208@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Ben Greear <greearb@candelatech.com> [040730 09:25]:
> Cheng Jin wrote:
> 
> >As of 2.6.6 kernel, TCP Westwood, which mainly addresses issues in 
> >wireless networks, BIC TCP, and TCP Vegas are all included besides TCP 
> >NewReno, although not enabled by default.  The others can be downloaded 
> >from the given websites.  There are probably others that I forgot to 
> >mention.  Apologies to them in advance.
> 
> Any chance Westwood will get into the 2.4 kernel as well?
> 
> >Making the current TCP more ``efficient'' by increasing cwnd faster is not 
> >an adequate solution, although doing that will likely produce higher 
> >throughput in today's Internet.  We also must consider issues such as 
> >fairness to other flows, stability of the network in terms of queue
> >oscillation and packet loss, and how well these solutions would scale in 
> >future networks.  A lot of experiments are still needed to determine which 
> >is the most appropriate under what circumstances.
> 
> Both of the two that I read about (Highspeed TCP and FAST tcp)
> did indeed increase the cwnd faster, unless I mis-understood
> the papers.  Granted they do it in clever ways...

At least H-TCP does increase the alpha parameter to increase the rate
of change, but it also changes the beta parameter in accordance with the
alpha, this is done to maintain fairness and the other good values we
want to promote.

You can find the patches for Linux 2.4.23 on the Hamilton website at:
http://hamilton.ie/net/main.htm?index

The parameters are changed in a mode-switch method so that H-TCP will
work together with TCP and will work also on low Bandwidth Delay Product
networks.

Baruch 
