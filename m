From: Kosta Todorovic <kostodo@gmail.com>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: Tue, 22 Mar 2005 11:18:11 +0400
Message-ID: <efe3b0060503212318529cb823@mail.gmail.com>
References: <efe3b00605031021513b7268d1@mail.gmail.com>
	 <efe3b006050320111879022bc2@mail.gmail.com>
	 <1111346944.1094.91.camel@jzny.localdomain>
	 <200503211959.36089.jdmason@us.ibm.com>
Reply-To: Kosta Todorovic <kostodo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Francois Romieu <romieu@fr.zoreil.com>,
        Ben Greear <greearb@candelatech.com>, jgarzik@pobox.com,
        tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200503211959.36089.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Kosta, Can you confrim that the tulip driver works for you on a 32bit system?

Just tried on 32bit mode and exactly the SAME thing happens with the
tulip driver as in 64bit mode.

Its very strange thought, for a few seconds there was traffic passing
through the card (icmp echo reply). The it stopped and would answer
anymore. I tried restarting the interface a few times but no joy.

When i checked with 'mii-tool -w' i keep showing the NIC trying to
autonegotiate and saying it Failed. Also i can see the card switching
back and forth from 10mbps to 100mbps.

I'm slightly confused ;)
