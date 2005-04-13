From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP performance drop 2.6.6->2.6.7
Date: Wed, 13 Apr 2005 11:20:36 -0700
Message-ID: <20050413112036.752a22f4@dxpl.pdx.osdl.net>
References: <425C493B.5040206@ev-en.org>
	<20050412160752.46c82f0c@dxpl.pdx.osdl.net>
	<425C60DD.5090007@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <425C60DD.5090007@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 13 Apr 2005 00:59:25 +0100
Baruch Even <baruch@ev-en.org> wrote:

> Stephen Hemminger wrote:
> > On Tue, 12 Apr 2005 23:18:35 +0100
> > Baruch Even <baruch@ev-en.org> wrote:
> >>The setup for the tests, vanilla kernels, dummynet with 100 Mbit/s and 
> >>40ms rtt using the BIC protocol. No patches applied whatsoever.

What is the queue length? Better yet what is the exact commandline
used to setup dummynet.

> >>
> >>iperf tests for 2.6.6 get about 90Mbit/s while 2.6.7 gets 30Mbit/s.
> > 
> > 
> > Haven't measured old kernels recently. But haven't seen that with the
> > newest stuff I tested last night. At 40ms delay  with netem
> > over 1G to 100M bridge.
> > 	Reno	99.6
> > 	Vegas	61.6
> > 	BIC	  97.8
> > 	Hstcp	 99.4
> > 	Westwood 99.4
> 
> I've now tested 2.6.11.7 and I get about 50Mbit/s, it starts at about 
> 100 and drops to about 45. Tested for about a minute but it didn't show 
> signs of recovery.
> 
> > What are your sysctl settings. 
> 
> Attached.
> 
> Baruch
