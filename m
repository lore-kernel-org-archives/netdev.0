From: "CIT/Paul" <xerox@foonet.net>
Subject: RE: Route cache performance under stress
Date: Wed, 11 Jun 2003 15:40:47 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <000901c33051$5ae64330$4a00000a@badass>
References: <87he6wbdkz.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Jamal Hadi'" <hadi@shell.cyberus.ca>,
	"'Pekka Savola'" <pekkas@netcore.fi>,
	"'Simon Kirby'" <sim@netnation.com>,
	"'David S. Miller'" <davem@redhat.com>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "'Florian Weimer'" <fw@deneb.enyo.de>, <ralph+d@istop.com>
In-Reply-To: <87he6wbdkz.fsf@deneb.enyo.de>
List-Id: netdev.vger.kernel.org

Wait until you see a DoS attack at 2 million pps with random source ips
and ports and dst ports and tcp flags and the only consistant thing
about the entire attack is the destination ip :>  can we say.. Null
route quick!! 

Paul xerox@foonet.net http://www.httpd.net


-----Original Message-----
From: Florian Weimer [mailto:fw@deneb.enyo.de] 
Sent: Wednesday, June 11, 2003 3:48 PM
To: ralph+d@istop.com
Cc: Jamal Hadi; Pekka Savola; CIT/Paul; 'Simon Kirby'; 'David S.
Miller'; netdev@oss.sgi.com; linux-net@vger.kernel.org
Subject: Re: Route cache performance under stress


Ralph Doncaster <ralph@istop.com> writes:

>> Assuming the attacker has a 100mbps link to you, yes ;->
>
> A script kiddie 0wning a box with a FE connection is nothing.  During 
> what was probably the worst DOS I got hit with, one of my upstream 
> providers said they were seeing about 600mbps of traffic related to 
> the attack.

Yes, these numbers keep growing.  By today's standards, 6000 Mbps
shouldn't be too surprising. 8-(

One of the servers I keep running was recently flooded with 1500-byte
UDP packets, Fast Ethernet line rate.  It definitely happens if your
pipes are fat enough.

