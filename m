From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: Instead of IP addresses the kernel started to show zero's
Date: Tue, 9 Oct 2012 15:36:01 +0300
Message-ID: <20121009123601.GA21710@mwanda>
References: <20120921182703.GH16609@beaver>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexey Vlasov <renton@renton.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120921182703.GH16609@beaver>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add netdev to the CC list.

regards,
dan carpenter

On Fri, Sep 21, 2012 at 10:27:04PM +0400, Alexey Vlasov wrote:
> Hi.
> 
> Here it writes LOG module (netfilter) in syslog:
> ====
> Sep 21 22:24:04 l24 kernel: ipsec:SYN-OUTPUT-HTTP IN= OUT=eth0
> SRC=0000000000000000 DST=0000000000000000 LEN=60 TOS=0x00 PREC=0x00
> TTL=64 ID=9042 DF PROTO=TCP SPT=51169 DPT=80 WINDOW=14600 RES=0x00 SYN
> URGP=0 UID=545369 GID=155
> ====
> 
> This is recent, here go zero's again.
> ====
> cat /proc/net/xt_recent/j-brute
> src=0000000000000000 ttl: 117 last_seen: 4349942400 oldest_pkt: 1
> 4349942400
> src=0000000000000000 ttl: 119 last_seen: 4349968063 oldest_pkt: 1
> 4349968063
> ====
> 
> Can it be fixed without restarting the box?
> Thanks.
> 
> # uname -a
> Linux l24 3.4.6 ...
> 
> --
> BRGDS. Alexey Vlasov.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
