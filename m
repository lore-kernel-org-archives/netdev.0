From: Mike Galbraith <mgalbraith@suse.de>
Subject: Re: qlge driver corrupting kernel memory
Date: Fri, 11 May 2012 13:38:21 +0200
Message-ID: <1336736301.7361.144.camel@marge.simpson.net>
References: <1336474818.21924.94.camel@marge.simpson.net>
	 <20120508120748.GA3504@oc1711230544.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55241 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752657Ab2EKLi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2012 07:38:27 -0400
In-Reply-To: <20120508120748.GA3504@oc1711230544.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-08 at 09:07 -0300, Thadeu Lima de Souza Cascardo wrote: 
> On Tue, May 08, 2012 at 01:00:18PM +0200, Mike Galbraith wrote:
> > Greetings network wizards,
> > 
> > $subject is happening in an 2.6.32 enterprise kernel with the driver
> > updated to what looks to me to be 2.6.38 or so.
> > 
> > Allegedly, IFF boxen are running dual CNAs with storage and LAN sharing
> > a port, $subject happens fairly regularly.  Rummaging in crashdumps
> > seems to show corruption happens because we somehow end up stuffing
> > loads of frags into skb_shared_info, scribbling all over the place.
> > 
> > Before I proceed, what I know about skbs can be found here..
> > 
> >     http://vger.kernel.org/~davem/skb_data.html
> > 
> > ..and that's the sum and total ;-)
> > 
> > I guess the first thing I should ask is whether anyone has seen such
> > scribbling with this driver.  Known issue would be a case of happiness,
> > but I doubt that will be the case from searching, so onward.
> > 
> 
> Hi, Mike.
> 
> From what you describe, I suspect this is related to this fix:
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=782428535e0819b5b7c9825cd3faa2ad37032a70
> 
> Please, apply and report if that works for you.

Nope, box exploded.  I haven't seen a dump yet, but expect it'll be more
of the same scribbling.

-Mike
