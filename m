From: jamal <hadi@cyberus.ca>
Subject: unregister_netdev Annoyance WAS(Re: ing_filter debug messages
Date: 31 Dec 2004 11:48:17 -0500
Message-ID: <1104511697.1048.308.camel@jzny.localdomain>
References: <20041230160643.GD24603@wiggy.net>
	 <1104469666.1049.231.camel@jzny.localdomain>
	 <20041231093827.GG24603@wiggy.net>
	 <1104491510.1047.234.camel@jzny.localdomain>
	 <20041231131553.GA7460@wiggy.net>
	 <1104505838.1048.273.camel@jzny.localdomain>
	 <20041231154844.GA11511@wiggy.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
In-Reply-To: <20041231154844.GA11511@wiggy.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-12-31 at 10:48, Wichert Akkerman wrote:
> Previously jamal wrote:
> > Try also the attached patch with netfilter on and your rules installed.
> 
> That seems to do the trick: I no longer see the debug messages appear.
> The tunnel still works as well.
> 
> However, the unregister_netdev problem still persists.

I am pretty sure its a different problem. Quick scan shows the
register/unregister state machine may be at fault. 
Just changed the subject because there have been threads on this topic
that other people have been discussing that i havent followed.
Lets see if this gets their attention - If it doesnt i will poke around.

cheers,
jamal
