From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH v2 -mm 2/9] netconsole: Remove bogus check
Date: Tue, 10 Jul 2007 04:05:24 -0500
Message-ID: <20070710090524.GK11115@waste.org>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in> <20070710091930.23907.24600.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:33102 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758777AbXGJJGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 05:06:25 -0400
Content-Disposition: inline
In-Reply-To: <20070710091930.23907.24600.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 10, 2007 at 02:49:30PM +0530, Satyam Sharma wrote:
> From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> 
> [2/9] netconsole: Remove bogus check
> 
> The (!np.dev) check in write_msg() is bogus (always false), because:
> np.dev is set by netpoll_setup(), which is called by the target init
> code in init_netconsole() _before_ register_console() => write_msg() cannot
> be triggered unless netpoll_setup() returns with success. And that will not
> happen if netpoll_setup() failed to set np.dev. Also np.dev cannot go from
> under us while netconsole is loaded. This is because netpoll_setup() grabs
> a reference for us on that dev. So let's remove the pointless check.
> 
> Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
Mathematics is the supreme nostalgia of our time.
