From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] net: poll/select low latency socket support
Date: Tue, 25 Jun 2013 16:36:14 -0700 (PDT)
Message-ID: <20130625.163614.1867701213174099145.davem@davemloft.net>
References: <20130624072751.26134.78163.stgit@ladj378.jer.intel.com>
	<20130624072803.26134.41593.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	erdnetdev@gmail.com, bhutchings@solarflare.com,
	andi@firstfloor.org, hpa@zytor.com, eilong@broadcom.com,
	or.gerlitz@gmail.com, amirv@mellanox.com, alexr@mellanox.com,
	eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130624072803.26134.41593.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Mon, 24 Jun 2013 10:28:03 +0300

> select/poll busy-poll support.
> 
> Split sysctl value into two separate ones, one for read and one for poll.
> updated Documentation/sysctl/net.txt
> 
> Add a new poll flag POLL_LL. When this flag is set, sock_poll will call
> sk_poll_ll if possible. sock_poll sets this flag in its return value
> to indicate to select/poll when a socket that can busy poll is found.
> 
> When poll/select have nothing to report, call the low-level
> sock_poll again until we are out of time or we find something.
> 
> Once the system call finds something, it stops setting POLL_LL, so it can
> return the result to the user ASAP.
> 
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>

Looks good, applied, thanks!
