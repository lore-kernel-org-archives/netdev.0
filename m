From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH -mm 4/9] netconsole: Introduce netconsole_netdev_notifier
Date: Wed, 4 Jul 2007 08:59:25 -0500
Message-ID: <20070704135925.GC11115@waste.org>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in> <20070704110759.28520.37301.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762265AbXGDOAh@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070704110759.28520.37301.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 04, 2007 at 04:37:59PM +0530, Satyam Sharma wrote:
> From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> 
> [4/9] netconsole: Introduce netconsole_netdev_notifier
> 
> To update fields of underlying netpoll structure at runtime on
> corresponding NETDEV_CHANGEADDR or NETDEV_CHANGENAME notifications.

It's not obvious that we want to do that.

I can have a host with DHCP that uses netconsole to log to a private
network address. This breaks that.

-- 
Mathematics is the supreme nostalgia of our time.
