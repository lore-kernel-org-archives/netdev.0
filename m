From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: limited number if iptable rules on 64bit hosts
Date: Wed, 2 Feb 2005 17:38:53 -0500
Message-ID: <20050202223853.GA29237@ti64.telemetry-investments.com>
References: <20050202133851.GA9680@suse.de> <20050202222516.GA15440@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Olaf Hering <olh@suse.de>
Content-Disposition: inline
In-Reply-To: <20050202222516.GA15440@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Feb 02, 2005 at 11:25:16PM +0100, Olaf Hering wrote:
> it triggers the first -ENOMEM in
> net/ipv4/netfilter/ip_tables.c:do_replace
> 
> sizeof(struct ipt_table_info)+SMP_ALIGN(tmp.size)*NR_CPUS == 67108992 bytes
> 
> 128+524288*128==67108992
> 
> (sizeof(struct ipt_table_info) + (((tmp.size) + (1 << 7)-1) & ~((1 << 7)-1)) * 128)
> 
> hmm, no braces missing.

I don't have time to look now [I'm running for the door],
but that's possibly the vmalloc() limit of 64M (67108864) ?

Regards,

	Bill Rugolsky
