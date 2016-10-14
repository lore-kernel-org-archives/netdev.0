From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH 4/6] fjes: Implement debug mode for fjes driver
Date: Fri, 14 Oct 2016 07:30:20 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A74193885@G01JPEXMBYT21>
References: <1476176047-18670-1-git-send-email-izumi.taku@jp.fujitsu.com>
        <1476176120-18859-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <20161013.101930.1034896203915503108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:49413 "EHLO
        mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754216AbcJNHaa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 03:30:30 -0400
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
        by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 9D524AC022C
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 16:30:22 +0900 (JST)
In-Reply-To: <20161013.101930.1034896203915503108.davem@davemloft.net>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David,

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, October 13, 2016 11:20 PM
> To: Izumi, Taku/泉 拓
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH 4/6] fjes: Implement debug mode for fjes driver
> 
> From: Taku Izumi <izumi.taku@jp.fujitsu.com>
> Date: Tue, 11 Oct 2016 17:55:20 +0900
> 
> > This patch implements debug mode for fjes driver.
> > You can get firmware activity information by enabling
> > debug mode. This is useful for debugging.
> >
> > To enable debug mode, write value of debugging mode to
> > debug_mode file in debugfs:
> >
> >   # echo 1 > /sys/kernel/debug/fjes/fjes.0/debug_mode
> >
> > To disable debug mode, write 0 to debug_mode file in debugfs:
> >
> >   # echo 0 > /sys/kernel/debug/fjes/fjes.0/debug_mode
> >
> > Firmware activity information can be retrieved via
> > /sys/kernel/debug/fjes/fjes.0/debug_data file.
> >
> > Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> 
> There is no reason to use debugfs for this, we have facilities such
> as ETHTOOL_SET_DUMP et al. that you can use to implement this.

  Thank you for reviewing.
  I see. I'll rewrite this patch to use ethtool.

Sincerely,
Taku Izumi
