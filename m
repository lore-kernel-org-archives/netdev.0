From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPV6: use macro for M-Flag and clean-up
Date: Sun, 29 Jun 2003 11:14:35 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306291114120.20809-100000@excalibur.intercode.com.au>
References: <20030628.203011.05536524.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030628.203011.05536524.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 28 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> -		fh->frag_off = htons(0x0001);
> +		fh->frag_off = htons(IP6_MF);

Please use __constant_htons().


- James
-- 
James Morris
<jmorris@intercode.com.au>
