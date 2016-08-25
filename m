From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH 1/1] net: add killer E2500 device id
Date: Thu, 25 Aug 2016 11:58:14 +0200
Message-ID: <20160825095814.GA26023@bistromath.localdomain>
References: <BN3PR0401MB1457768A72BE42070D34E581C0ED0@BN3PR0401MB1457.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Owen Lin <olin@rivetnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47246 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756158AbcHYKHm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 06:07:42 -0400
Content-Disposition: inline
In-Reply-To: <BN3PR0401MB1457768A72BE42070D34E581C0ED0@BN3PR0401MB1457.namprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Owen,

2016-08-25, 03:33:11 +0000, Owen Lin wrote:
> Add Killer E2500 device ID in alx driver.
> 
> Signed-off-by: Owen Lin olin@rivetnetworks.com
> 
> --------------------------------------------------------------------------------

This line shouldn't be here (it will end up in the commit message).


> diff -up1rN alx_orig/main.c alx/main.c
> --- alx_orig/main.c	2016-08-25 11:12:34.170447500 +0800
> +++ alx/main.c	2016-08-25 11:24:12.026853000 +0800

That patch won't apply.  The patch should be generated from the root
directory, and include the full path of the files you're modifying, so
that the patch can be applied from the root directory of the kernel
tree.  i.e. the paths should be of the form

    a/drivers/net/ethernet/atheros/alx/main.c

The easiest way to create patches that apply properly is to use the
git tree and the `git format-patch` tool.


Thanks,

-- 
Sabrina
