From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv4: Enable use of 240/4 address space
Date: Mon, 21 Jan 2008 03:19:59 -0800 (PST)
Message-ID: <20080121.031959.83378394.davem@davemloft.net>
References: <20080118.111319.30002290.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.64.0801191443410.27831@fbirervta.pbzchgretzou.qr>
	<20080120.003019.119068925.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: jengelh@computergmbh.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ak@suse.de, vaf@cisco.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37266
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756361AbYAULTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 06:19:54 -0500
In-Reply-To: <20080120.003019.119068925.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sun, 20 Jan 2008 00:30:19 +0900 (JST)

> In article <Pine.LNX.4.64.0801191443410.27831@fbirervta.pbzchgretzou.qr> (at Sat, 19 Jan 2008 14:44:13 +0100 (CET)), Jan Engelhardt <jengelh@computergmbh.de> says:
> 
> > From 84bccef295aa9754ee662191e32ba1d64edce2ba Mon Sep 17 00:00:00 2001
> > From: Jan Engelhardt <jengelh@computergmbh.de>
> > Date: Fri, 18 Jan 2008 02:10:44 +0100
> > Subject: [PATCH] IPv4: enable use of 240/4 address space
> > 
> > This short patch modifies the IPv4 networking to enable use of the
> > 240.0.0.0/4 (aka "class-E") address space as propsed in the internet
> > draft draft-fuller-240space-00.txt.
> > 
> > Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

I've applied this to net-2.6.25, thanks everyone.

I know I said we should deploy this as fast as possible,
but we are really coming down the wire as far as releasing
2.6.24 is concerned and I don't want to put anything into
my pushes to Linus that he might not like and thus cause
the entire set of bug fixes to be rejected.

Thanks again.
