From: James Morris <jmorris@intercode.com.au>
Subject: Re: [2.6.0-test1-mm1] TCP connections over ipsec hang after a few
 seconds
Date: Sun, 20 Jul 2003 15:58:13 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307201552580.22965-100000@excalibur.intercode.com.au>
References: <6uk7aeab33.fsf@zork.zork.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Sean Neakums <sneakums@zork.net>
In-Reply-To: <6uk7aeab33.fsf@zork.zork.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 19 Jul 2003, Sean Neakums wrote:

> twenty.  The problem seems unrelated to the amount of data
> transferred; I've tried both bulk rsync transfers and ssh sessions.
> I've also tested the same boxes over 100baseT; still happens.

It sounds a bit like a pmtu problem related to the wireless bridge, but 
that would be dependent on amount of data transferred and should not 
happen on 100baseT.

Transport mode (just blowfish encryption) looks to be working ok for me,
I'm able to ftp uncompressed kernel tarballs between two boxes over 
gigabit ethernet with no apparent problems.



- James
-- 
James Morris
<jmorris@intercode.com.au>
