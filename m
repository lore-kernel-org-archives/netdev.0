From: John Goerzen <jgoerzen@complete.org>
Subject: Re: [Bugme-new] [Bug 4274] New: ipv6: Unknown symbol tcp_timer_bug_msg
Date: Wed, 2 Mar 2005 13:51:10 -0600
Message-ID: <20050302195110.GA27736@excelhustler.com>
References: <20050302091907.19bb2b2e.akpm@osdl.org> <20050303.023706.64945563.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@wide.ad.jp>
Content-Disposition: inline
In-Reply-To: <20050303.023706.64945563.yoshfuji@wide.ad.jp>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2005 at 02:37:06AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> In article <20050302091907.19bb2b2e.akpm@osdl.org> (at Wed, 2 Mar 2005 09:19:07 -0800), Andrew Morton <akpm@osdl.org> says:
> 
> > modprobe ipv6 fails with:
> > 
> > ipv6: Unknown symbol tcp_timer_bug_msg
> 
> Please try this.

That fixed it.  Thanks!

-- John

> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> 
> ===== net/ipv4/tcp_timer.c 1.30 vs edited =====
> --- 1.30/net/ipv4/tcp_timer.c	2005-02-23 03:45:32 +09:00
> +++ edited/net/ipv4/tcp_timer.c	2005-03-03 02:26:20 +09:00
> @@ -38,6 +38,7 @@
>  
>  #ifdef TCP_DEBUG
>  const char tcp_timer_bug_msg[] = KERN_DEBUG "tcpbug: unknown timer value\n";
> +EXPORT_SYMBOL(tcp_timer_bug_msg);
>  #endif
>  
>  /*
> 
> -- 
> Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
> GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
> 
