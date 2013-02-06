From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression caused by 1d2024f61ec14bdb0c57a97a3fe73685abc2d198?
Date: Wed, 06 Feb 2013 10:09:54 -0800
Message-ID: <1360174194.28557.46.camel@edumazet-glaptop>
References: <20130206114321.GA13497@redhat.com>
	 <1360156059.28557.28.camel@edumazet-glaptop>
	 <20130206155049.GB14735@redhat.com>
	 <1360167332.28557.36.camel@edumazet-glaptop>
	 <20130206174228.GA16991@redhat.com>
	 <1360172565.28557.44.camel@edumazet-glaptop>
	 <20130206180537.GA17228@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, stephen.s.ko@intel.com,
	jeffrey.t.kirsher@intel.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, sony.chacko@qlogic.com, mchan@broadcom.com,
	jitendra.kalsaria@qlogic.com, eilong@broadcom.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33416 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab3BFSJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 13:09:57 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so936510pad.38
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 10:09:57 -0800 (PST)
In-Reply-To: <20130206180537.GA17228@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 20:05 +0200, Michael S. Tsirkin wrote:

> 
> OK this means cbf1de72324a8105ddcc3d9ce9acbc613faea17e might be needed
> in 3.8 and maybe -stable, otherwise macvtap crashes when LRO is set.
> 

You may be right : My issue was an accounting error in a rarely used
path (qdisc on ingress). Yours is definitely more serious ;)
