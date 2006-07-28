From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Fri, 28 Jul 2006 12:55:41 -0700 (PDT)
Message-ID: <20060728.125541.78492222.davem@davemloft.net>
References: <20060717155822.315389000@hp.com>
	<20060728.005542.21593420.davem@davemloft.net>
	<44CA5B61.3010704@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@epoch.ncsc.mil,
	jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32211
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030286AbWG1Tzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 15:55:41 -0400
To: paul.moore@hp.com
In-Reply-To: <44CA5B61.3010704@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Fri, 28 Jul 2006 14:45:53 -0400

> I'm happy to drop this hook as it *looks* like the MLSXFRM patchset is
> going to make it which has some of the accept hooks I was hoping to get,
> but figured I stood a "snowballs chance in hell" trying to get it in
> solely for use with CIPSO :)  I'll drop this on the next release of the
> NetLabel patchset and assuming both the NetLabel and the MLSXFRM
> patchset make it into the 2.6.19 release I'll issue another small
> patchset then to integrate into the new LSM hooks for accept.  I'd do it
> now but I think it would cause too much of a mess with patch
> dependencies/collisions/etc.

The MLSXFRM stuff is already queued up in my 2.6.19 tree at:

	master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.19.git

so you can make your work relative to that if you wish.
