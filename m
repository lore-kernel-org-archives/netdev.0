From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: Fix oops in dev_ifsioc()
Date: Fri, 19 Dec 2008 08:11:04 +0000
Message-ID: <20081219081104.GB7189@ff.dom.local>
References: <20081219070431.GA7189@ff.dom.local> <494B552B.1010602@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia@diku.dk, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:42080 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101AbYLSILK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 03:11:10 -0500
Received: by nf-out-0910.google.com with SMTP id d3so123133nfc.21
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2008 00:11:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <494B552B.1010602@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 19, 2008 at 04:02:51PM +0800, Wang Chen wrote:
> Jarek Poplawski said the following on 2008-12-19 15:04:
> > A command like this: "brctl addif br1 eth1" issued as a user gave me
> > an oops when bridge module wasn't loaded. It's caused by using a dev
> > pointer before checking for NULL.
...
> Subject will be changed, sorry.
> Seems Julia  is doing "Move a dereference below a NULL test" check,
> but why the coccinelle missed this one?

Probably because it's quite fresh?

Jarek P.
