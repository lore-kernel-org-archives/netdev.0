From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
	feature-negotiation patches
Date: Tue, 2 Sep 2008 10:50:55 -0300
Message-ID: <20080902135055.GB8346@ghostprotocols.net>
References: <20080828194336.GJ9193@ghostprotocols.net> <20080830172501.GB26846@gerrit.erg.abdn.ac.uk> <20080901164633.GA6456@gerrit.erg.abdn.ac.uk> <20080901.142055.193705447.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43277 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422AbYIBN5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2008 09:57:05 -0400
Content-Disposition: inline
In-Reply-To: <20080901.142055.193705447.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Sep 01, 2008 at 02:20:55PM -0700, David Miller escreveu:
> From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Date: Mon, 1 Sep 2008 18:46:33 +0200
> 
> > The set contains the same patches as submitted to netdev/dccp@vger last week.
> > Thanks to contributions from several people, this revised set contains several
> > improvements. I have just verified that the set is still fully bisectable.
> 
> >From what I can tell the only person who reviewed this set was Arnaldo
> and he was only able to review about half of the patches before passing
> out.
> 
> Surely I can imagine he would come up with similar fixups and commentary
> for the rest of these patches were he given the chance to do so.
> 
> So I'd like to wait and give him the chance to provide that feedback.


Hi,

	Thanks Dave, but now there is also Wei looking over this patch
set, I'll try to get back to this soon, but I'm busy with other stuff, so if
you think it is ok don't wait too much for me :-)

	I just would love if the core code doesn't get things that are
specific to a particular CCID implementation, as I saw in this patchset in
the net/dccp/feat.c file. struct ccid and ccid_operations were designed
to avoid that.

- Arnaldo
       
