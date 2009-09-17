From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 2/2] net: remove print_mac as it's not anymore used
Date: Thu, 17 Sep 2009 07:48:55 +0200
Message-ID: <20090917054855.GA29905@game.jcrosoft.org>
References: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
 <1253146059-4169-2-git-send-email-plagnioj@jcrosoft.com>
 <20090916.205159.191998627.davem@davemloft.net>
 <20090916.205417.253183573.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:47664 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752761AbZIQGBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 02:01:43 -0400
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
> 
> Did you actually run grep on the entire tree to see if it's still used
> anywhere or did you only check drivers/net/ and net/ or something
> equally lazy?
Yes I've done a git grep print_mac + cscope on the current Linus tree and
see no more use of print_mac

Best Regards,
J.
