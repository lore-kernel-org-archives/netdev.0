From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 00:39:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16101.3260.654259.708727@robur.slu.se>
References: <20030608.225837.115923841.davem@redhat.com>
	<001801c32e50$57ef0750$4a00000a@badass>
	<20030609071330.GD20613@netnation.com>
	<20030609.015648.55736734.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, xerox@foonet.net, hadi@shell.cyberus.ca,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   Robert.Olsson@data.slu.se, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030609.015648.55736734.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 > BTW, ignoring juno, Robert Olsson has some pktgen hacks that allow
 > that to generate new-dst-per-packet DoS like traffic.  It's much
 > more effective than Juno-z
 > 
 > Robert could you should these guys your hacks to do that?

Sure.
What a discussion... Well I'm happy for the past lazy days. 


I've include some references in the experiment from last week and it should 
be interesting for people in this discussion.

Summary:
Forwarding experiment with different rates of new incoming destinations/sec. 
Ranging from DoS attack to single destination flow. With full 123k routes.

http://robur.slu.se/Linux/net-development/experiments/router-flow-test.html


Your latest patch looks interesting... good thinking. Operations and tuning 
would be simplier. Hope to have time for a test tomorrow. Testing is very 
manual work still.

Cheers.

						--ro
