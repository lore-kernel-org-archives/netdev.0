From: Paul Jackson <pj@sgi.com>
Subject: Re: [Patch][RFC] Disabling per-tgid stats on task exit in taskstats
Date: Mon, 3 Jul 2006 08:55:48 -0700
Message-ID: <20060703085548.8db09dff.pj@sgi.com>
References: <44892610.6040001@watson.ibm.com>
	<449C6620.1020203@engr.sgi.com>
	<20060623164743.c894c314.akpm@osdl.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Valdis.Kletnieks@vt.edu, jlan@engr.sgi.com,
	balbir@in.ibm.com, csturtiv@sgi.com, linux-kernel@vger.kernel.org,
	hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx1-ext.sgi.com ([192.48.179.11]:30693 "EHLO
	omx1.americas.sgi.com") by vger.kernel.org with ESMTP
	id S932083AbWGCP4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 11:56:21 -0400
To: Shailabh Nagar <nagar@watson.ibm.com>
In-Reply-To: <44A93179.2080303@watson.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shailabh wrote:
> Yes. If no one registers to listen on a particular CPU, data from tasks 
> exiting on that cpu is not sent out at all.

Excellent.


> So I chose to use the "cpulist" ascii format that has been helpfully 
> provided in include/linux/cpumask.h (by whom I wonder :-)

Excellent.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
