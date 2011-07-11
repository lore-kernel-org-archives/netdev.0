From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: [LTP] Update for CAN LTP tests
Date: Mon, 11 Jul 2011 18:15:13 +0200
Message-ID: <20110711161513.GB31575@saboteur.suse.cz>
References: <20090512094631.26592.81609.sendpatchset@subratamodak.linux.ibm.com>
 <4E19987B.2030507@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Subrata Modak <subrata@linux.vnet.ibm.com>,
	ltp-list <ltp-list@lists.sf.net>,
	socketcan-users@lists.berlios.de,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50851 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757955Ab1GKQNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 12:13:47 -0400
Content-Disposition: inline
In-Reply-To: <4E19987B.2030507@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!
> > Would you also like to send a patch to update the testcases for CAN in LTP
> > (http://ltp.cvs.sourceforge.net/viewvc/ltp/ltp/testcases/network/can/filter-tests/) ?
> > These tests were originally picked up from:
> > http://svn.berlios.de/wsvn/socketcan/trunk/test/?rev=877&amp;sc=1
> 
> Dear Subrata,
> 
> attached you'll find a major update for the LTP tests dealing with CAN filters
> and the CAN frame flow down to the CAN netdevice and vice versa.
> 
> The patch removes all the obsolete stuff from the source code directory you
> originally picked the tests from. I added two new tools that also reside on
> the referenced SVN:
> 
> tst-filter: New filter test tool in *one* programm (easy to use & handle)
> tst-rcv-own-msgs: Checks the CAN frame flow inside the networking stack
> 
> Additionally the virtual CAN driver needs to be loaded with a special
> commandline option to perform the CAN frame flow test correctly.
> 
> The tests & the scripts are much clearer to me now. If it meets your
> requirements consider to apply this patch to the LTP repository.

Could you pretty please create signed patch(es) (git could create them
for you) so we could commit them into LTP repository.

-- 
Cyril Hrubis
chrubis@suse.cz
