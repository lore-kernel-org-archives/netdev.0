From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: PROBLEM: nd_tbl not a public symbol in net/ipv6/ndisc.c
Date: Mon, 31 Jan 2005 17:20:22 +0900 (JST)
Message-ID: <20050131.172022.93845025.yoshfuji@linux-ipv6.org>
References: <Pine.OSF.4.58.0501310903220.211@igor.urz.unibas.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Christian.Tschudin@unibas.ch
In-Reply-To: <Pine.OSF.4.58.0501310903220.211@igor.urz.unibas.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.OSF.4.58.0501310903220.211@igor.urz.unibas.ch> (at Mon, 31 Jan 2005 09:04:34 +0100 (MET)), Christian Tschudin <Christian.Tschudin@unibas.ch> says:

> Our LUNAR project (underlay for wireless multihop networks)
> stumbled over the same problem that at least two other projects
> (infiniband, and mipv6) also experienced many months ago:
> 
>   The neighbor table 'nd_tbl' in net/ipv6/ndisc.c
>   is not accessible from other modules.
:
> +EXPORT_SYMBOL(nd_tbl);

I disagree.
Basically, ndisc.c is the only user of that structure and
I cannot find why you really need this symbol.

--yoshfuji
