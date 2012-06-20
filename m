From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Wed, 20 Jun 2012 11:14:53 +0200
Message-ID: <1340183693.4604.844.camel@edumazet-glaptop>
References: <1340170590.4604.784.camel@edumazet-glaptop>
	 <1340180223.4604.828.camel@edumazet-glaptop>
	 <1340181847.4604.840.camel@edumazet-glaptop>
	 <20120620.020401.1089501454050120720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51175 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726Ab2FTJO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 05:14:58 -0400
Received: by bkcji2 with SMTP id ji2so5939465bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 02:14:57 -0700 (PDT)
In-Reply-To: <20120620.020401.1089501454050120720.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 02:04 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 20 Jun 2012 10:44:07 +0200
> 
> > (put_page assumes order-0 page)
> 
> But it certainly can handle compound pages, I thought?

Yes, I forgot the GFP_COMP ;)

Oh well, time for a coffee
