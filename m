From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH, TAKE 2] [IPV6] XFRM: extract xfrm_lookup() from
 ip6_dst_lookup() (is Re: [PATCH][IPv6] separation xfrm_lookup from
 ip6_dst_lookup)
Date: Tue, 26 Oct 2004 12:55:39 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026.125539.84990576.yoshfuji@linux-ipv6.org>
References: <20040801195135.16734846.davem@redhat.com>
	<20040828.014935.131415609.yoshfuji@linux-ipv6.org>
	<417D6FD0.7010903@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kazunori@miyazawa.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Brian.Haley@hp.com, davem@davemloft.net
In-Reply-To: <417D6FD0.7010903@hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <417D6FD0.7010903@hp.com> (at Mon, 25 Oct 2004 17:27:44 -0400), Brian Haley <Brian.Haley@hp.com> says:

> Attached is a patch that fixes that and also brings the rt0_hdr struct 
> in-line with RFC 3542 by removing the "bitmap" field.

Good catch but please do not change bitmap.
I applied it into my tree, without changing bitmap.

David, I'll send bk URL including this very soon.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
