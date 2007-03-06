From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: linux 2.6 Ipv4 routing enhancement (fwd)
Date: Tue, 6 Mar 2007 19:46:15 +0100
Message-ID: <17901.46839.606994.201834@robur.slu.se>
References: <Pine.LNX.4.62.0703050953090.24653@alpha.cflinux.hu>
	<17901.19158.878755.883322@robur.slu.se>
	<Pine.LNX.4.62.0703061539380.17441@alpha.cflinux.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@vger.kernel.org
To: Richard Kojedzinszky <krichy@cflinux.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:53615 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966007AbXCFSqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 13:46:18 -0500
In-Reply-To: <Pine.LNX.4.62.0703061539380.17441@alpha.cflinux.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Richard Kojedzinszky writes:

 > Sorry for sending the tgz with .svn included. And i did not send 
 > instructions.
 > To do a test with fib_trie, issue
 > $ make clean all ROUTE_ALG=TRIE & ./try a
 > with fib_radix:
 > $ make clean all ROUTE_ALG=RADIX & ./try a
 > with fib_lef:
 > $ make clean all ROUTE_ALG=LEF SBBITS=4 & ./try a

 Thanks. First I'll use to do my testing in kernel context and in the 
 forwarding path with full semantic match so it's not that easy to compare.  
 But I'll take a look. BTW the you test so you do correct prefix matching?
 
 FYI. some old fib work on robur.slu.se

 # Look with just hlist
  /pub/Linux/net-development/fib_hlist/

 # 24 bit hash lookup
  /pub/Linux/net-development/fib_hash2/
 
 And some hlist/hash2/trie comparisons in:
 /pub/Linux/tmp/trie-talk-kth.pdf

 Cheers
					--ro
