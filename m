From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: pktgen problem (skb refcount) in 2.6.12-rc1
Date: Mon, 4 Apr 2005 13:41:27 +0200
Message-ID: <16977.10215.725020.64329@robur.slu.se>
References: <20050402191132.GF1890@sunbeam.de.gnumonks.org>
	<16976.16774.728707.368646@robur.slu.se>
	<20050404052642.GE9155@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20050404052642.GE9155@sunbeam.de.gnumonks.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Harald Welte writes:

 Hello!

 >>>   I've tried to track the problem down, and I've confirmed that skb->users
 >>> never goes down to 1 but instead stays at '2'.

 > no changes in kernel config.  I've reviewed pktgen changes and couldn't
 > find something that would cause the problem.  It always only
 > atomic_inc'ed the ussage cound (and decrements only in error path) which
 > is perfectly fine.

 OK! Thanks.

 > As for e1000 and or generic TX path changes, I don't have the time to
 > review them now, sorry :(  That's why I posted it to netdev, to let
 > people who have an idea about the committed changes know that there is
 > an issue.
 
 Well if it's skb leak it will be seen.
 
					--ro
