From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Fix ipchains/ipfw modules
Date: Fri, 24 Sep 2004 11:07:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924110750.40c5f187.davem@davemloft.net>
References: <m3fz57915u.fsf@averell.firstfloor.org>
	<415439FC.10401@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, netdev@oss.sgi.com, coreteam@netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <415439FC.10401@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Sep 2004 12:15:08 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Patrick McHardy fixed this in a different way in the "Re: [PATCH] Warn 
> people that ipchains and ipfwadm are going away." lkml thread :-)
> 
> His explanation:
> 
> "Fixed by this patch. The conntrack protocols need ip_ct_log_invalid
> which is defined in ip_conntrack_standalone, so ip_conntrack is
> loaded automatically before ipchains. This patch moves it over to
> ip_conntrack_core."

Yes, and that fix is on it's way to Linus today some time.
