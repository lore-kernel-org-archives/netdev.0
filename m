From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: invaild TCP/UDP matching when ipv6 extension header
 exists
Date: Thu, 26 Feb 2004 12:37:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040226123732.6132fdbc.davem@redhat.com>
References: <200401310649.PAA00050@toshiba.co.jp>
	<200402200612.PAA12001@toshiba.co.jp>
	<20040220093158.3c12ea9a.davem@redhat.com>
	<200402260406.NAA16034@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <200402260406.NAA16034@toshiba.co.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 26 Feb 2004 13:05:50 +0900 (JST)
Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp> wrote:

> This patch is for linux 2.4.26-pre1 .
> 
> Summery:
> tcp_match() and udp_match() in ip6tables.c assume that previous header
> of TCP/UDP header is IPv6 Header. So, for example, 1st of fragmented UDP
> packet, AHed packets can't correctly match the rules which use
> "--sport" and so on.

Also applied, thank you.
