From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH net-next] net: ndisc.c: reduce size of
 __ndisc_fill_addr_option()
Date: Wed, 31 May 2017 00:06:32 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15BB2927@cnshjmbx02>
References: <1495836052-8377-1-git-send-email-cugyly@163.com>
         <20170529.233009.1607319852930338432.davem@davemloft.net>
 <1496115666.2618.9.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dsahern@gmail.com" <dsahern@gmail.com>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
        "cugyly@163.com" <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:43136 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750925AbdEaAVh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:21:37 -0400
In-Reply-To: <1496115666.2618.9.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi joe,

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Joe Perches
> Sent: Tuesday, May 30, 2017 11:41 AM
> To: David Miller; cugyly@163.com
> Cc: netdev@vger.kernel.org; dsahern@gmail.com; YUAN Linyu
> Subject: Re: [PATCH net-next] net: ndisc.c: reduce size of
> __ndisc_fill_addr_option()
> 
> On Mon, 2017-05-29 at 23:30 -0400, David Miller wrote:
> > From: yuan linyu <cugyly@163.com>
> > Date: Sat, 27 May 2017 06:00:52 +0800
> >
> > > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > >
> > > Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> >
> > Applied, thanks.
> 
> OK, but is it really safe though?
> 
> Could "space" (an int) ever be negative after
> subtracting "pad" and "data_len"?
It's safe, check
int space = __ndisc_opt_addr_space(data_len, pad);
space is maximum aligned value.
And I check current pad, the maximum value is 2.
