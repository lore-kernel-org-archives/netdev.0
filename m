From: jamal <hadi@cyberus.ca>
Subject: Re: IMQ / new Dummy device post.
Date: 18 Apr 2004 17:07:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082322448.1041.329.camel@jzny.localdomain>
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
	 <4082AE45.7030101@dsl.pipex.com>  <4082E66D.2020707@dsl.pipex.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <4082E66D.2020707@dsl.pipex.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-04-18 at 16:34, Andy Furniss wrote:


> Hmm second thoughts - if I can route packets to dummy after demasquerade 
> then I don't need to mark - I can use u32 as I do now to seperate per 
> IP. Am I missing something here?

The problem is dummy had some speacial reason for existence in the old
days of slip/ppp dummy acts as blackhole; 
some apps insist(ed) on getting a static IP address
on primary interface when you are offline. So people would typically
setup routes to the dummy device where packets just get swalloed.

I have a feeling there are people who still use this functionality
somewhere in the globe (sorry i am from .ca dont know what that means
anymore;->). And i dont want to break this functionality.
So what i was thinking is i will have dummy spare any fwmarked packets
and reinject them back.
Another alternative is to just fsck this backward compatibility mode
because people could use blackhole routes today.
Yet another alternative is to create a brand new device and call it
something like imq2. For such little code, this may be overkill.

cheers,
jamal


 
