From: David Brownell <david-b@pacbell.net>
Subject: Re: 2.6.11-rc2 TCP ignores PMTU ICMP (Re: Linux 2.6.11-rc2)
Date: Thu, 27 Jan 2005 15:11:57 -0800
Message-ID: <200501271511.58086.david-b@pacbell.net>
References: <200501232251.42394.david-b@pacbell.net> <priv$1106815487.koan@shadow.banki.hu> <200501271128.48411.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Ford <david+challenge-response@blue-labs.org>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        Art Haas <ahaas@airmail.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Janos Farkas <jf-ml-k1-1087813225@lk8rp.mail.xeon.eu.org>
In-Reply-To: <200501271128.48411.david-b@pacbell.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I just got an interesting "I see these problems too" report.  It
may provide a useful clue.  According to "Art Haas" <ahaas@airmail.net>:

> I'm running the current BK kernel now, and I'm not seeing the problems
> right now because, I found, I do not have some of the IP masquerading
> modules installed on my machine. When these modules get installed then
> the cvs/rsync problems appear. 
 
I do have CONFIG_IP_NF_TARGET_MASQUERADE=y on the system where I'm
seeing this, though it's not doing anything just now.  Haven't yet
made time to see if disabling it improves things ... but if that's
a factor, it could explain why more people aren't suffering with
this problem.

- Dave
