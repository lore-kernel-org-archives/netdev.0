From: Paul Jackson <pj@sgi.com>
Subject: Re: [Patch][RFC] Disabling per-tgid stats on task exit in taskstats
Date: Tue, 4 Jul 2006 12:59:09 -0700
Message-ID: <20060704125909.1265fadc.pj@sgi.com>
References: <44892610.6040001@watson.ibm.com>
	<449CAA78.4080902@watson.ibm.com>
	<20060623213912.96056b02.akpm@osdl.org>
	<449CD4B3.8020300@watson.ibm.com>
	<44A01A50.1050403@sgi.com>
	<20060626105548.edef4c64.akpm@osdl.org>
	<44A020CD.30903@watson.ibm.com>
	<20060626111249.7aece36e.akpm@osdl.org>
	<44A026ED.8080903@sgi.com>
	<20060626113959.839d72bc.akpm@osdl.org>
	<44A2F50D.8030306@engr.sgi.com>
	<20060628145341.529a61ab.akpm@osdl.org>
	<44A2FC72.9090407@engr.sgi.com>
	<20060629014050.d3bf0be4.pj@sgi.com>
	<200606291230.k5TCUg45030710@turing-police.cc.vt.edu>
	<20060629094408.360ac157.pj@sgi.com>
	<20060629110107.2e56310b.akpm@osdl.org>
	<44A57310.3010208@watson.ibm.com>
	<44A5770F.3080206@watson.ibm.com>
	<20060630155030.5ea1faba.akpm@osdl.org>
	<44A5DBE7.2020704@watson.ibm.com>
	<44A5EDE6.3010605@watson.ibm.com>
	<20060702215350.2c1de596.pj@sgi.com>
	<44A93179.2080303@watson.ibm.com>
	<20060703093148.5e61a7e4.pj@sgi.com>
	<44A9B1A9.20106@watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Valdis.Kletnieks@vt.edu, jlan@engr.sgi.com,
	balbir@in.ibm.com, csturtiv@sgi.com, linux-kernel@vger.kernel.org,
	hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:32418 "EHLO omx2.sgi.com")
	by vger.kernel.org with ESMTP id S932367AbWGDT7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 15:59:42 -0400
To: Shailabh Nagar <nagar@watson.ibm.com>
In-Reply-To: <44A9B1A9.20106@watson.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shailabh wrote:
> Perhaps I should use the the other ascii format for specifying cpumasks 
> since its more amenable
> to specifying an upper bound for the length of the ascii string and is 
> more compact ?

Eh - basically - I don't have a strong opinion either way.

I have a slight esthetic preference toward using list of ranges format
from shell scripts and shell prompts, and using the 32-bit hex words
from C code:

	17-26,44-47		# shell - list of ranges
	0000f000,07fe0000	# C - 32-bit hex words

Since the primary interface you are working with is C code, that would
mean I'd slightly prefer the 32-bit hex word variant.

>From what I've seen neither of the reasons you gave for preferring
the 32-bit hex word format are persuasive (even though they both
lead to the same conclusion as I preferred ;):

    Which is more compact depends on that particular bit pattern
    you need to represent.  See for example the examples above.

    The lack of a perfect upper bound on the list of ranges format
    is a theoretical problem that I have never seen in practice.
    Only pathological constructs exceed six ascii characters per
    set bit.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
