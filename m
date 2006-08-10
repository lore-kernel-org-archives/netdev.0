From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 0/5] net socket family patches
Date: Thu, 10 Aug 2006 11:55:59 -0700
Message-ID: <20060810115559.deba44fd.rdunlap@xenotime.net>
References: <20060809183138.332023530@localhost.localdomain>
	<20060809.170641.02297593.davem@davemloft.net>
	<Pine.NEB.4.64.0608100532010.9039@ukato.freeshell.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:60856 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1161177AbWHJSxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 14:53:17 -0400
Received: from midway.site ([71.117.253.75]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 11:53:12 -0700
To: Alexey Toptygin <alexeyt@freeshell.org>
In-Reply-To: <Pine.NEB.4.64.0608100532010.9039@ukato.freeshell.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Aug 2006 05:36:13 +0000 (UTC) Alexey Toptygin wrote:

> On Wed, 9 Aug 2006, David Miller wrote:
> 
> > From: Stephen Hemminger <shemminger@osdl.org>
> > Date: Wed, 09 Aug 2006 11:31:38 -0700
> >
> >> These patches cleanup the net socket family interface and
> >> convert it to RCU. This is new stuff that should go into 2.6.19
> >> (if it is ready). Andrew could you put it in -mm as well?
> >
> > Andrew pulls net-2.6.19 so there is no need to ask him to
> > put networking patches explicitly into -mm
> 
> I've been wondering - are the relationships of which of the various kernel 
> trees pull patches from which other ones documented anywhere? If so, I'd 
> love to read about it.

Not really documented AFAIK, except what Andrew pulls into his -mm tree
for testing.  His announcements [used to] list which (git or other) trees that
he has merged, along with non-tree patches.  Now that is just in the
patch-list file, e.g., see
  ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc3/2.6.18-rc3-mm2/patch-list
and then search for "git-" to see which git trees it contains.

If you go down the maintainer's hierarchy, it gets more fuzzy. :)
Jeff Garzik pulls the wireless tree from John Linville and several
net driver trees from Francois Romieu, e.g.  And Jeff pulls SATA
patches from Tejun Heo.

DaveM pulls net patches from Yoshifuji etc.

James Bottomley usually maintains 2 SCSI git trees:  one for
2.6.current-rc fixes and one for 2.6.next merges.  He recently documented
that in email to linux-scsi@vger.kernel.org.

Most kernel git trees can be seen at www.kernel.org/git/.
Most kernel patch trees (git or other) are now listed in the
MAINTAINERS file.

HTH.
---
~Randy
