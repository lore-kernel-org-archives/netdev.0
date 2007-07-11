From: Joel Becker <Joel.Becker@oracle.com>
Subject: Re: [PATCH v2 -mm 8/9] netconsole: Support multiple logging targets
Date: Tue, 10 Jul 2007 21:29:48 -0700
Message-ID: <20070711042948.GS1011@tasint.org>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in> <20070710092001.23907.39876.sendpatchset@cselinux1.cse.iitk.ac.in> <e9e943910707100323o35cb0316i5d3f21584ad8e4ae@mail.gmail.com> <Pine.LNX.4.64.0707110340370.2445@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Duane Griffin <duaneg@dghda.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:19254 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbXGKEaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 00:30:25 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707110340370.2445@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 11, 2007 at 03:47:09AM +0530, Satyam Sharma wrote:
> Hmm, I put it in there because I expected that the user must have had
> at least one target configured (added to target_list) if he's got the
> module loaded/built-in (and netconsole registered), which is when this
> function would be triggered anyway.

	Loading the module won't happen without a config, but there's no
requirement that a built-in netconsole has a kernel command-line
argument.  I always build netconsole for my kernels.  Sure, I usually do
it as a module, but if I build a monolithic kernel I compile it in.
That doesn't mean I always have a server, let alone a netconsole= option
:-)

Joel

-- 

"When choosing between two evils, I always like to try the one
 I've never tried before."
        - Mae West

Joel Becker
Principal Software Developer
Oracle
E-mail: joel.becker@oracle.com
Phone: (650) 506-8127
