From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC][PATCH] static builtin CCIDs was  Re: [PATCH 2/5] dccp:
	Auto-load (when supported) CCID plugins for negotiation
Date: Thu, 18 Dec 2008 06:41:10 +0100
Message-ID: <20081218054110.GA6298@gerrit.erg.abdn.ac.uk>
References: <20081216111908.GI14518@ghostprotocols.net> <20081216.133200.229085084.davem@davemloft.net> <20081216222559.GR14518@ghostprotocols.net> <20081216.151151.220977047.davem@davemloft.net> <20081217131347.GS14518@ghostprotocols.net> <20081217182038.GV14518@ghostprotocols.net> <20081217183041.GW14518@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>, mirqus@gmail.com,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:64031 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750778AbYLRFlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 00:41:32 -0500
Content-Disposition: inline
In-Reply-To: <20081217183041.GW14518@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Arnaldo:
| Em Wed, Dec 17, 2008 at 04:20:38PM -0200, Arnaldo Carvalho de Melo escreveu:
| > > IOW we're back to my suggestion on looking at
| > > tcp_set_congestion_control(). :-)
| > 
| > I tried to test this using ttcp over loopback but the tree seems broken
| > somehow, with or without this patch I'm getting:
| > 
| > Could not activate 0 at /home/acme/git/net-next-2.6/net/dccp/feat.c:1176
| > 
| > I tried doing a quick chase on this one but failed miserably, Gerrit,
| > any ideas?
| 
| Well, without the patch the problem was that dccp_ccid2 was not being
| autoloaded, as soon as I manually loaded it, ttcp worked. Now to see
| why...
I have acked your patch but haven't had time to compile and test it.
Will do this in due course and integrate it into the test tree. 

With regard to the error message, this says that the feature with index 0
could not be activated. According to table 6.4 in RFC 4340 this is a bug
because it tries to activate a reserved feature.

Will do in-depth testing later on today.
