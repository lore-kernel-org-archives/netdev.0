From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: linux-next: manual merge of the net tree with the
	wireless-current tree
Date: Mon, 30 Nov 2009 08:48:52 -0800
Message-ID: <20091130164852.GA1008@bougret.hpl.hp.com>
References: <20091126141055.d8c67798.sfr@canb.auug.org.au> <1259227989.32372.32.camel@johannes.local> <20091126130153.GA3697@tuxdriver.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:63332 "EHLO
	gundega.hpl.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402AbZK3QtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 11:49:20 -0500
Content-Disposition: inline
In-Reply-To: <20091126130153.GA3697@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 26, 2009 at 08:01:53AM -0500, John W. Linville wrote:
> On Thu, Nov 26, 2009 at 10:33:09AM +0100, Johannes Berg wrote:
> > On Thu, 2009-11-26 at 14:10 +1100, Stephen Rothwell wrote:
> > > Hi all,
> > > 
> > > Today's linux-next merge of the net tree got a conflict in
> > > net/wireless/wext.c between commit
> > > 9fed059667d35fca9288460106e92dbb8ba35ea1 ("WE: Fix set events not
> > > propagated") from the  tree and commit
> > > 3d23e349d807177eaf519d444677cee86b1a04cf ("wext: refactor") from the net
> > > tree.
> > > 
> > > The latter deleted the file that the former modified.  I just ignored the
> > > wireless-current change and removed the file (which seems to have been
> > > done in the latter change anyway).
> > 
> > The fix should probably have gone to wext-core.c instead?
> 
> Yes.  That's the way I did it in the merge-test branch of wireless-next-2.6.
> 
> Thanks,
> 
> John

	Thanks for fixing that while I was busy in vacation ;-)
	Have fun...

	Jean
