From: Paul Jakma <paul@clubi.ie>
Subject: Re: primary and secondary ip addresses
Date: Thu, 16 Dec 2004 16:48:31 +0000 (UTC)
Message-ID: <Pine.LNX.4.61.0412161630460.9233@sheen.jakma.org>
References: <41912F7A.6000408@redhat.com> <Pine.LNX.4.61.0411100034320.10593@filer.marasystems.com>
 <20041216092831.GO2862@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Henrik Nordstrom <hno@marasystems.com>, Neil Horman <nhorman@redhat.com>,
        linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20041216092831.GO2862@sunbeam.de.gnumonks.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Dec 2004, Harald Welte wrote:

> ... and why does removing the primary address remove all secondary 
> addresses.

Because applications may have state which relies on the implied 
source address selection, I'd hazard a guess. If you dont remove the 
secondaries, you might break the apps - but i dont know.

(certainly, the primary/secondary thing in kernel is useful - though, 
it possibly doesnt need to be in kernel.)

> This makes it complicated if you have one interface 
> with multiple ip addresse, that change over time (failover, let's 
> say.)  You don't know yet, which address you need to remove, 
> because you don't know which of your peers fails.

That's bad planning. ;)

You should assign your failover addresses seperately to your primary. 
Ie, the primary should never fail over - its unique to the 
machine/interface.

> So you have all this complicated userspace magic that checks 
> whether the address that is about to be deleted is the primary, and 
> if yes, re-add all the other addresses.  If if is a secondary, 
> you're happy and only need to delete that one.

Ick ;)

> Can anyone comment what the idea of all this was?

Source address selection. ?

> Thanks.

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
Prizes are for children.
  		-- Charles Ives, upon being given, but refusing, the
  		   Pulitzer prize
