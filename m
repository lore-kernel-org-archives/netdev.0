From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: fix payload length of reassembled packet
Date: Thu, 12 Jun 2003 02:27:53 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612.022753.56899094.yoshfuji@linux-ipv6.org>
References: <20030612.020716.37975763.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0306112014560.2321-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0306112014560.2321-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0306112014560.2321-100000@netcore.fi> (at Wed, 11 Jun 2003 20:15:45 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> > +	payload_len = (head->data - head->nh.raw) - sizeof(struct ipv6hdr) + fq->len - 8;
> 
> s/8/sizeof(struct frag_hdr)/ ?

Yes, sizeof(struct frag_hdr). 
I, however, use 8 for now to focus on the bug itself.
(We have more "8"s there which should be substituted.)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
