From: jamal <hadi@cyberus.ca>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: 22 Mar 2005 09:56:52 -0500
Message-ID: <1111503412.1081.49.camel@jzny.localdomain>
References: <efe3b00605031021513b7268d1@mail.gmail.com>
	 <efe3b006050320111879022bc2@mail.gmail.com>
	 <1111346944.1094.91.camel@jzny.localdomain>
	 <200503211959.36089.jdmason@us.ibm.com>
	 <efe3b0060503212318529cb823@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jon Mason <jdmason@us.ibm.com>, Francois Romieu <romieu@fr.zoreil.com>,
        Ben Greear <greearb@candelatech.com>, jgarzik@pobox.com,
        tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
To: Kosta Todorovic <kostodo@gmail.com>
In-Reply-To: <efe3b0060503212318529cb823@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kosta,

As i told you earlier: You can NOT use mii-tool. This board uses SYM
PHY. 
Try finding out what the other side reports instead in terms of speed
and duplexity.

When you say switching back/forth between 10/100 - how can you tell
that? I think this may be your problem. Dont try to force speeds;
just let it AN.

Find something on the other side that is capable of reporting 
correctly like e1000 and test.

All i can tell you is this works on 32 bit machines - I cant validate 64
bit machines because i dont have one.

cheers,
jamal

On Tue, 2005-03-22 at 02:18, Kosta Todorovic wrote:
> > Kosta, Can you confrim that the tulip driver works for you on a 32bit system?
> 
> Just tried on 32bit mode and exactly the SAME thing happens with the
> tulip driver as in 64bit mode.
> 
> Its very strange thought, for a few seconds there was traffic passing
> through the card (icmp echo reply). The it stopped and would answer
> anymore. I tried restarting the interface a few times but no joy.
> 
> When i checked with 'mii-tool -w' i keep showing the NIC trying to
> autonegotiate and saying it Failed. Also i can see the card switching
> back and forth from 10mbps to 100mbps.
> 
> I'm slightly confused ;)
> 
