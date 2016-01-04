From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH net-next] net: Add l3mdev cgroup
Date: Mon, 4 Jan 2016 14:23:01 -0500
Message-ID: <20160104192301.GC3807@mtj.duckdns.org>
References: <1451925136-13327-1-git-send-email-dsa@cumulusnetworks.com>
 <20160104175836.GA11668@mtj.duckdns.org>
 <568ABFC3.3010803@cumulusnetworks.com>
 <20160104185936.GA3807@mtj.duckdns.org>
 <568AC534.1070308@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	shm@cumulusnetworks.com, roopa@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f196.google.com ([209.85.160.196]:33240 "EHLO
	mail-yk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbcADTXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 14:23:04 -0500
Content-Disposition: inline
In-Reply-To: <568AC534.1070308@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, David.

On Mon, Jan 04, 2016 at 12:17:08PM -0700, David Ahern wrote:
> None of the existing subsystems are relevant for configuring an L3
> networking domain, and it does not make sense to tie net_cls and net_prio to
> an L3 domain.

I don't have an answer for that but cgroup isn't a place to put such
stray configurations either.  Please figure out where the
configuration belongs first.  What you're proposing really isn't a
resource controller.  There's no resource being distributed
hierarchically.  It's just dumping configuration which hasn't found
its proper place into cgroup.

Thanks.

-- 
tejun
