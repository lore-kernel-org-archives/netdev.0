From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: regression caused by 1d2024f61ec14bdb0c57a97a3fe73685abc2d198?
Date: Thu, 7 Feb 2013 03:03:40 +0000 (UTC)
Message-ID: <kev5ic$tla$1@ger.gmane.org>
References: <20130206114321.GA13497@redhat.com>
 <1360156059.28557.28.camel@edumazet-glaptop>
 <20130206155049.GB14735@redhat.com>
 <1360167332.28557.36.camel@edumazet-glaptop>
 <20130206174228.GA16991@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:48436 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754478Ab3BGDEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 22:04:00 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1U3HmZ-0001J5-QF
	for netdev@vger.kernel.org; Thu, 07 Feb 2013 04:04:15 +0100
Received: from 14.205.47.183 ([14.205.47.183])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 04:04:15 +0100
Received: from xiyou.wangcong by 14.205.47.183 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 04:04:15 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 Feb 2013 at 17:42 GMT, Michael S. Tsirkin <mst@redhat.com> wrote:
>
> I see it sets gso_type but apparently only if mode is GRO?
> Will this still break if mode is set to LRO?

The comment inside skb_warn_if_lro() said:

        /* LRO sets gso_size but not gso_type, whereas if GSO is really
         * wanted then gso_type will be set. */
