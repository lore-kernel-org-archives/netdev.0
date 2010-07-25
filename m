From: John Haxby <john.haxby@oracle.com>
Subject: Re: [PATCH 1/2] netfilter: xtables: inclusion of xt_SYSRQ
Date: Sun, 25 Jul 2010 19:13:30 +0100
Message-ID: <65479A87-7576-42EF-9E6B-7BD6F1A78099@oracle.com>
References: <1271845618-28569-1-git-send-email-jengelh@medozas.de> <1271845618-28569-2-git-send-email-jengelh@medozas.de> <4BCEF6B4.8090105@trash.net> <alpine.LSU.2.01.1004211506280.10840@obet.zrqbmnf.qr> <4BCEFACC.7020804@trash.net> <alpine.LSU.2.01.1004211533410.21020@obet.zrqbmnf.qr> <4BD84992.5030909@oracle.com> <4BD84C23.2000301@oracle.com> <alpine.LSU.2.01.1004281701220.9518@obet.zrqbmnf.qr> <alpine.LSU.2.01.1007251848520.14790@obet.zrqbmnf.qr>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1007251848520.14790@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 25 Jul 2010, at 17:49, Jan Engelhardt wrote:

> 
> On Wednesday 2010-04-28 17:03, Jan Engelhardt wrote:
>> On Wednesday 2010-04-28 16:54, John Haxby wrote:
>>> 
>>> use-case I see -- the one I see is where the sys admins used to have a "crash
>>> trolley" which was a console and PS/2 keyboard which they could plug into a
>>> machine to get some information, but as many rack machines no longer have
>>> anything PS/2 and USB hot plug is unlikely to work on a sick machine
>> 
> 
> I still think we should merge this. A hold-up like this would have never 
> happened with staging drivers!
> 

Me too.   I've been caught up with other things, but Patrick's suggestion of a separate module only half worked out.

Using encapsulation sockets, to get the sysrq handled in BH context works well except that there are no encapsulation sockets for IPv6.  That, for me at least was a bit of a show stopper.

In exploring this, though, I did correct one weakness in the protocol.  An opportunistic hacker could take a sysrq packet and replay it to other hosts in the LAN in the hope that they have the same password (this is a realistic weakness rather than a theoretical one).   To counter this I simply added the target IP address to the hash.

Would you like me to submit that to xt_SYSRQ anyway?   (In a couple of weeks I'm afraid, I'm out for a while.)

jch