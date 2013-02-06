From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression caused by 1d2024f61ec14bdb0c57a97a3fe73685abc2d198?
Date: Wed, 06 Feb 2013 08:23:20 -0800
Message-ID: <1360167800.28557.40.camel@edumazet-glaptop>
References: <20130206114321.GA13497@redhat.com>
	 <1360156059.28557.28.camel@edumazet-glaptop>
	 <20130206155049.GB14735@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, stephen.s.ko@intel.com,
	jeffrey.t.kirsher@intel.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, sony.chacko@qlogic.com, mchan@broadcom.com,
	jitendra.kalsaria@qlogic.com, eilong@broadcom.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:56041 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754029Ab3BFQXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 11:23:23 -0500
Received: by mail-ie0-f177.google.com with SMTP id 16so2080705iea.8
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 08:23:23 -0800 (PST)
In-Reply-To: <20130206155049.GB14735@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 17:50 +0200, Michael S. Tsirkin wrote:

> Commit log talks about improved performance for lossy connections,
> in this case, isn't this something net core should set?
> 

I fail to see where net core could do that.

These drivers kind of bypass GRO, so they must provide skbs that are
100% correct.
