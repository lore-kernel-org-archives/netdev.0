From: Craig Sanders <cas@taz.net.au>
Subject: Re: PROBLEM: kernel oops when tickless. 2.6.28.x to 2.6.31.3
Date: Wed, 14 Oct 2009 01:14:34 +1100
Message-ID: <20091013141434.GA10613@taz.net.au>
References: <20091013090554.GB28715@taz.net.au>
 <4AD45169.2030507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759970AbZJMOPN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AD45169.2030507@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 13, 2009 at 12:07:37PM +0200, Eric Dumazet wrote:
> This particular problem should/could be fixed in 2.6.31.4 by commit 
> d99927f4d93f36553699573b279e0ff98ad7dea6
> (net: Fix sock_wfree() race)
> 
> Please try to reproduce your tickless problem on 2.6.31.4 or latest
> Linus git tree


I've already compiled 2.6.31.4 @1000HZ, but I'll compile again and try
2.6.31.4 tickless in the morning. i'll report back with the result - it
usually takes a few days after booting before the Oops occurs, so if it
goes well that might not be until the weekend or early next week.

any idea what actually triggers it?  pppoe? malformed packets from the
internet?  udp/514 packets for rsyslogd?


thanks,

craig

-- 
craig sanders <cas@taz.net.au>
