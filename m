From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: added sysctl for maximum number of addresses
Date: Fri, 16 Jan 2004 00:34:33 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116.003433.120676843.yoshfuji@linux-ipv6.org>
References: <20040115.213014.133549139.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0401151721380.16629-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, vnuorval@tcs.hut.fi, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0401151721380.16629-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0401151721380.16629-100000@netcore.fi> (at Thu, 15 Jan 2004 17:23:23 +0200 (EET)), Pekka Savola <pekkas@netcore.fi> says:

> On Thu, 15 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> > In some configuration, we need addresses more than 16 addresses per interface.
> > This pach adds new sysctl for configuring the maximum number of addresses 
> > per interface.
> 
> Doesn't 16 addresses per interface sound like an awfully small number?  
> Consider a web service which wants to have a different IP address per 
> virtual host.  These are not really uncommon.

My point is the value becomes configurable.
"16" is consistent with current behavior.
I do not change the default value with this patch.

If you think it is too small, feel free to submit a patch to increase 
the default value.

Thanks.

--yoshfuji
