From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 2/2] net: remove print_mac as it's not anymore used
Date: Thu, 17 Sep 2009 08:09:10 +0200
Message-ID: <20090917060910.GC29905@game.jcrosoft.org>
References: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
 <1253146059-4169-2-git-send-email-plagnioj@jcrosoft.com>
 <20090916.205159.191998627.davem@davemloft.net>
 <20090916.205417.253183573.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:37654 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754207AbZIQGV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 02:21:57 -0400
Content-Disposition: inline
In-Reply-To: <20090916.205417.253183573.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20:54 Wed 16 Sep     , David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 16 Sep 2009 20:51:59 -0700 (PDT)
> 
> > From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> > Date: Thu, 17 Sep 2009 02:07:39 +0200
> > 
> >> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> > 
> > Applied.
> 
> Actually I had to revert.  It's still used by the FCOE stack in
> the scsi layer.
I've found the commit that already fix it

commit 66d6faec2f874cf6bf9bd4900966584ea9feae3d
Refs: v2.6.31-rc7-23-g66d6fae
Author:     Johannes Berg <johannes@sipsolutions.net>
AuthorDate: Wed Jul 15 17:21:14 2009 +0200
Commit:     James Bottomley <James.Bottomley@suse.de>
CommitDate: Sat Aug 22 17:51:56 2009 -0500

[SCSI] fcoe: convert to %pM

Best Regards,
J.
