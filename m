From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 18:58:05 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409211856260.9906-100000@netcore.fi>
References: <20040922.001448.73843048.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: laforge@gnumonks.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040922.001448.73843048.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> > > It's worse in the sense that there is more space in each subnet for
> > > doing aggressive probing -- but this may not be a big issue with a
> > > good algorithm and a threshold.
> > 
> > So what is that 'good algorithm'.  The current Linux algorithm is from
> > my point of view (only tested with ipv4) not very good when it comes to
> > high numbers of neighbours.
> 
> Well, of course, we should limit number of total entries.
> 
> If we have enough memory for usual use,
> we should not purge the "probably reachable" routes
> (REACHABLE, STALE, DELAY, and PROBE) neighbours.
> Probably, we should split neighbour entries to two parts.
>  - INCOMPLETE
>  - REACHABLE, STALE, DELAY and PROBE
> Which means, we should NOT purge "known" entries by unknown entries.

This still doesn't take a stance on rate-limiting the ND/ARP packets,
in case that there still is enough memory, but some kind of attack is
clearly underway.  Should it still be done?  Consider 100Kpps of
router-generated ARP/ND probes -- not good!

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
