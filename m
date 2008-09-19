From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: zd1211rw (2.6.26.5) and ipv6
Date: Fri, 19 Sep 2008 19:02:45 +0300 (EEST)
Message-ID: <alpine.LRH.2.00.0809191853330.2297@netcore.fi>
References: <20080916175008.GR4610@crazydwarves.org> <20080919141229.GA1177@crazydwarves.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Victor NOEL <victor.noel@crazydwarves.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:50215 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754730AbYISQDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2008 12:03:03 -0400
In-Reply-To: <20080919141229.GA1177@crazydwarves.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Sep 2008, Victor NOEL wrote:
> It looks like no one is interested in this, but I found something
> else about this problem and maybe this will interest someone :)
>
> I find a way to make it work : when I do, for example, a ping6
> www.kame.net, like I said, nothing happens, but if, at the same
> time, in another terminal I run "tcpdump -i wlan0 ip6" to see
> what is happening, then the ping6 just starts to work !

Yeah, this seems to happen from time to time. :-(

Earlier this year, zd1211rw (all mac80211 stack users, really) were 
broken in a similar fashion, and you could workaround this by running 
tcpdump like you described:

http://www.mail-archive.com/git-commits-head@vger.kernel.org/msg41572.html

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
