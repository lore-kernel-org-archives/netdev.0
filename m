From: jamal <hadi@cyberus.ca>
Subject: Re: IMQ / new Dummy device post.
Date: 18 Apr 2004 16:53:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082321582.1039.319.camel@jzny.localdomain>
References: <407E5905.9070108@dsl.pipex.com>
	 <1082031313.1039.13.camel@jzny.localdomain>
	 <407EE3E5.8060200@dsl.pipex.com>
	 <1082087553.1035.287.camel@jzny.localdomain>
	 <4080356F.4020609@dsl.pipex.com>
	 <1082145341.1026.125.camel@jzny.localdomain>
	 <40810957.6030209@dsl.pipex.com>
	 <1082203795.1043.18.camel@jzny.localdomain>
	 <4081A824.5020107@dsl.pipex.com>
	 <1082298480.1041.94.camel@jzny.localdomain>
	 <4082AE45.7030101@dsl.pipex.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <4082AE45.7030101@dsl.pipex.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-04-18 at 12:35, Andy Furniss wrote:

> Connmark is a netfilter patch which is required by the type of P2P 
> limiting/marking projects on sf.net that could mark bittorrent traffic. 

just from the sounds of it, appears it may be able to mark a group of
related flows with the same fwmark.

> It is incompatable with the connbytes patch which I use to mark the 
> first x KB of new connections. Doing this lets me send new TCps to a 
> short queue which is capped at 50% of my bandwidth. This means that some 
> packets get dropped and the slowstart phase is ended before it's 
> exponential nature floods my ISP buffer.

seems very similar in concept to what Alex (alex@pilotsoft.com) was
trying to achieve.

> > To accomodate your need for b), the idea would be as follows:
> > packet gets demasquared, mark it with a fwmark
> 
> I guess you really mean mark then demasquerade.

Either should work fine.

 
> OK I can see this as a possibility - assuming I can mark. Maybe conmark 

sounds like connmark maybe what you want.

> will be OK with connbytes sometime. I don't really know how to use it, 
> but if it is possible to mark egress connections in output and have 
> connmark match their incoming packets that would be a solution. I 
> haven't got a clue if connmark can do this, though, just speculating.
>
> Does anyone else know, and why it's not compatable with connbytes?
> 

some of the netfilter people should be able to help.

cheers,
jamal
