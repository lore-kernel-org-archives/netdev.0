From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: use macro for M-Flag and clean-up
Date: Sun, 29 Jun 2003 11:25:44 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030629.112544.42878077.yoshfuji@linux-ipv6.org>
References: <20030628.203011.05536524.yoshfuji@linux-ipv6.org>
	<Mutt.LNX.4.44.0306291114120.20809-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0306291114120.20809-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Mutt.LNX.4.44.0306291114120.20809-100000@excalibur.intercode.com.au> (at Sun, 29 Jun 2003 11:14:35 +1000 (EST)), James Morris <jmorris@intercode.com.au> says:

> On Sat, 28 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> 
> > -		fh->frag_off = htons(0x0001);
> > +		fh->frag_off = htons(IP6_MF);
> 
> Please use __constant_htons().

No. We don't use __constant_hton{s,l} in runtime code
since October, 2002.  We use hton{s,l} when we can.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
