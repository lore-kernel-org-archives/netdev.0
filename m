From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: TSQ accounting skb->truesize degrades throughput for large
 packets
Date: Mon, 9 Sep 2013 05:28:50 +0000 (UTC)
Message-ID: <l0jmai$qhd$1@ger.gmane.org>
References: <20130906101635.GI14104@zion.uk.xensource.com>
 <1378472268.31445.15.camel@edumazet-glaptop> <522A049A.7000105@citrix.com>
 <1378486840.31445.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:50809 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751075Ab3IIF3M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 01:29:12 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VIu29-0003ZB-Ul
	for netdev@vger.kernel.org; Mon, 09 Sep 2013 07:29:09 +0200
Received: from 117.57.171.128 ([117.57.171.128])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 07:29:09 +0200
Received: from xiyou.wangcong by 117.57.171.128 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 07:29:09 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 06 Sep 2013 at 17:00 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-09-06 at 17:36 +0100, Zoltan Kiss wrote:
>
>> So I guess it would be good to revisit the default value of this 
>> setting.
>
> If ixgbe requires 3 TSO packets in TX ring to get line rate, you also
> can tweak dev->gso_max_size from 65535 to 64000.
>

We observe similar regression on ixgbe driver, also virtio_net driver.
