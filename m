From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][IPSEC] IPsec policy can be matched by ICMP type and
 code
Date: Mon, 09 Aug 2004 18:03:17 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809.180317.110200874.yoshfuji@linux-ipv6.org>
References: <20040809175404.301bd60a@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
In-Reply-To: <20040809175404.301bd60a@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040809175404.301bd60a@localhost> (at Mon, 9 Aug 2004 17:54:04 +0900), Masahide Nakamura <nakam@linux-ipv6.org> says:

> This patch makes that IPsec policy can be matched by ICMP type and
> code. Actually setkey(ipsec-tools) already has their interface so it
> follows setkey's manner where type/code are stored in selector. I
> added shortcuts for them as a trial. Please read the patch and its log
> below first.

Sorry, please do not apply this.
I notice that this does not seem to work on big-endian archs.

--yoshfuji
