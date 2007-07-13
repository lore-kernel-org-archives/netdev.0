From: KII Keiichi <k-keiichi@bx.jp.nec.com>
Subject: Re: [PATCH v2 -mm 2/9] netconsole: Remove bogus check
Date: Fri, 13 Jul 2007 22:41:09 +0900
Message-ID: <469780F5.8090100@bx.jp.nec.com>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in> <20070710091930.23907.24600.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933519AbXGMNnr@vger.kernel.org>
In-Reply-To: <20070710091930.23907.24600.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Satyam,

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
> 
Acked-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>

Thanks
-- 
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com 
