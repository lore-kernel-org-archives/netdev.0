From: jamal <hadi@cyberus.ca>
Subject: Discussion fucking closed WAS(Re: [2.4 PATCH] bugfix: ARP respond
	on all devices
Date: 19 Aug 2003 15:17:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061320636.1029.16.camel@jzny.localdomain>
References: <353568DCBAE06148B70767C1B1A93E625EAB57@post.pc.aspectgroup.co.uk>
	 <1061296544.30566.8.camel@dhcp23.swansea.linux.org.uk>
	 <1061317825.3744.7.camel@athena.fprintf.net>
	 <20030819112912.359eaea6.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Gryniewicz <dang@fprintf.net>, alan@lxorguk.ukuu.org.uk,
   richard@aspectgroup.co.uk, skraw@ithnet.com, willy@w.ods.org,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030819112912.359eaea6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Ok, go ahead and call my mama - tell her i used a bad word on a mailing
list.
Folks, this is a actually a republic model: in other words its a
democracy upto a certain level then there maybe a veto. 
You have been provided a facility to go and do what funky thing that
pleases you. Use ARPTABLEs; if you dont like it maintain your own
patches - you have that freedom; dont enforce your freedom on someone
actually doing the maintanace work - they have more important things to
worry about.

You can quote all the RFCs you want - it wont change anything soon. I
got tired of following same cyclic arguements. What Linux is doing is
conformant. What other people following CISCO are doing is also
conformant. RFCs are written in an ambigous language called english.
People actually (lately anyways) sneak in ambiguity to make their
implementation look correct. So please stop quoting stoopid RFCs. 

cheers,
jamal

On Tue, 2003-08-19 at 14:29, David S. Miller wrote:
> On 19 Aug 2003 14:30:26 -0400
> Daniel Gryniewicz <dang@fprintf.net> wrote:
> 
> > If you are not on a shared lan, then it will *ONLY* work if linux is
> > on the other end.  No other system will work.
> 
> And these other systems are broken.  (actually, older Cisco equipment
> correctly responds to the ARP regardless of source IP)
> 
> Just because some Cisco engineer says that it is correct doesn't
> make it is.
> 
> Consider the situation logically.  When you're replying to an
> ARP, _HOW_ do you know what IP addresses are assigned to _MY_
> outgoing interfaces and _HOW_ do you know what subnets _EXIST_
> on the LAN?
> 
> The answer to both is, you'd don't know these things _EVEN_ if
> you are a router/gateway.
> 
> Therefore there is no valid reason not to respond to an ARP using one
> source address as opposed to another.
> 
> 
