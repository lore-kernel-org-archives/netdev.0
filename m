From: alex@pilosoft.com
Subject: tc feature request/bounty
Date: Wed, 7 Apr 2004 23:36:02 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0404071815500.17154-100000@paix.pilosoft.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Currently, linux tc has very useful concept of a 'index' for a given
policy. However, I need to have policers on multiple hosts to share the
same index (and thus, know and police the aggregate traffic across a set 
of routers). 

I'd like to be able to share tc policers across a set of boxes. 
Unfortunately, I'm not knowledgeable enough myself to implement that, but 
I can throw some money at the pool and hope someone picks it up. ;)

Proposed design: 

Userland daemon that polls kernel tc structure every X milliseconds and
broadcasts current bps rate (assuming we are using ewma) to a set of IP
addresses. Configuration would have list of indices and list of IP
addresses these indices are broadcast to.

Kernel changes: Add netlink interface to look up/modify (by "injecting"  
traffic) policer's structures (interface to tcf_police_lookup and 
tcf_police_dump). 

Adding external traffic to policer structures is somewhat tricky, but I'm
sure it is possible. At this point, I only care about EWMA, which isn't
all that hard.

Budget and bounty: 300$


-alex
