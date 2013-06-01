From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] Fix the SELinux dynamic network access controls
Date: Fri, 31 May 2013 17:31:08 -0700 (PDT)
Message-ID: <20130531.173108.2170873839229968113.davem@davemloft.net>
References: <20130529173336.31888.29695.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, omoris@redhat.com,
	pwouters@redhat.com
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755037Ab3FAAbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:31:10 -0400
In-Reply-To: <20130529173336.31888.29695.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Wed, 29 May 2013 13:36:18 -0400

> Take #3 ... two changes here: the first is a simple reordering of the
> two patches and the second is stripping the SELinux patch (2/2 in this
> patchset) of everything but the bare bones changes needed to fix the
> problem in the 3.10-rcX tree.

Series applied, but longer term I'd like to see this handled by generation
counts or similar during lookup time.

Doing a GC every policy delete hurts policy delete performance, something
we worked really hard to make as light weight as possible given the
constraints.

Thanks.
