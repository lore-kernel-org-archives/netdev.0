From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bug 3610] New: kernel-2.6.9 breaks Amanda
Date: Mon, 25 Oct 2004 16:16:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025161632.55fa938b@zqx3.pdx.osdl.net>
References: <200410211647.i9LGlnp1030223@fire-1.osdl.org>
	<20041021121205.30556eac@zqx3.pdx.osdl.net>
	<41793958.3050306@nswc.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bill Ralph <wralph@nswc.navy.mil>
In-Reply-To: <41793958.3050306@nswc.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> >>Problem Description: Amanda clients exchanges UDP packets with the server giving
> >>it a TCP port number with which to connect in order to receive files to be
> >>dumped to tape. Under kernel-2.6.8.1 the sofware performs perfectly. Under
> >>kernel-2.6.9, with exactly the same Amanda software, the UDP packet exchange
> >>seems to occur, but no TCP connection between client and server occurs. The
> >>client eventually times out with messages like:
> >>    
> >>
> >
> >Could you capture a tcpdump of the exchange, especially the failed connection attempt?
> >  
> >
> Here are two traces, one on the Amanada server machine, one on the 
> client machine. Not very useful, as there is no sign that the server 
> even attempts to connect to the client with a TCP connection.

Is there a firewall that is blocking the connection for some reason.
Can you successfully make a TCP connection between the two machines with some other command?
ssh, telnet, ttcp

Perhaps this is another instance of an OpenBSD firewall stomping on window scaling.
