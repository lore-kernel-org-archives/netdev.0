From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Mon, 31 Jan 2005 14:42:52 +0900 (JST)
Message-ID: <200501310542.j0V5grsI029994@toshiba.co.jp>
References: <20050131.134559.125426676.yoshfuji@linux-ipv6.org>
	<41FDBB78.2050403@trash.net>
	<20050131.141636.20664459.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kozakai@linux-ipv6.org, herbert@gondor.apana.org.au,
        davem@davemloft.net, rmk+lkml@arm.linux.org.uk,
        Robert.Olsson@data.slu.se, akpm@osdl.org, torvalds@osdl.org,
        alexn@dsv.su.se, kas@fi.muni.cz, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050131.141636.20664459.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Mon, 31 Jan 2005 14:16:36 +0900 (JST)

> In article <41FDBB78.2050403@trash.net> (at Mon, 31 Jan 2005 06:00:40 +0100), Patrick McHardy <kaber@trash.net> says:
> 
> |We don't need this for IPv6 yet. Once we get nf_conntrack in we
> |might need this, but its IPv6 fragment handling is different from
> |ip_conntrack, I need to check first.
> 
> Ok. It would be better to have some comment but anyway...
> kozakai-san?

IMO, fix for nf_conntrack isn't needed yet. Because someone may change
IPv6 fragment handling in nf_conntrack.

Anyway, current nf_conntrack passes the original (not de-fragmented) skb to
IPv6 stack. nf_conntrack doesn't touch its dst.

Regards,
----------------------------------------
Yasuyuki KOZAKAI

Communication Platform Laboratory,
Corporate Research & Development Center,
Toshiba Corporation

yasuyuki.kozakai@toshiba.co.jp
----------------------------------------
