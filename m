From: bhartin@straus-frank.com
Subject: Re: r8169, 2.6.2-rc2, Sager 4780 laptop
Date: Tue, 6 Apr 2004 18:03:03 -0500 (CDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0404061758570.17117@edp12.straus-frank.int>
References: <Pine.LNX.4.58.0401261443190.7894@edp12.straus-frank.int>
 <20040126235559.A3832@electric-eye.fr.zoreil.com>
 <Pine.LNX.4.58.0404041553010.6853@edp12.straus-frank.int>
 <20040405002028.A8125@electric-eye.fr.zoreil.com>
 <Pine.LNX.4.58.0404061650310.20664@edp12.straus-frank.int>
 <20040407001815.C7833@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040407001815.C7833@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 7 Apr 2004, Francois Romieu wrote:

> Hmmm... Something like "no PHY Reset ack. Giving up." I guess. Ok, I'll
> add it to the queue, the locking between the phy_timer() and the irq handler
> looks strange.

I got my laptop back up and found the messages logged:

kernel: r8169: eth0: Reset RTL8169s PHY

I didn't see exactly at what point this started happening during the 
shutdown, but the message repeated about 500 times before the system 
logger was stopped.

Again, I've had no issues so far during normal use.  There are no abnormal 
timeouts, and transfer rates appear within normal ranges.  (I've only used 
it on 100bT switches so far, no 10bT or gigabit.)

> As a general note, do not hesitate to post on/Cc: netdev as it can be of
> interest to other people as well.

I meant to, but must have hit no when Pine asked about replying to all 
recipients.

> Thanks for the report.

Not a problem at all.  I'm just glad to finally get this thing working!

Bradley Hartin - bhartin@straus-frank.com
Communications and Network Administrator
Straus-Frank Company
