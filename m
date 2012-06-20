From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Wed, 20 Jun 2012 10:44:07 +0200
Message-ID: <1340181847.4604.840.camel@edumazet-glaptop>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>
	 <1340170590.4604.784.camel@edumazet-glaptop>
	 <1340180223.4604.828.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51265 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831Ab2FTIoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 04:44:11 -0400
Received: by bkcji2 with SMTP id ji2so5917628bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 01:44:10 -0700 (PDT)
In-Reply-To: <1340180223.4604.828.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 10:17 +0200, Eric Dumazet wrote:

> Strange, I did again benchs with order-2 allocations and got good
> results this time, but with latest net-next, maybe things have changed
> since last time I did this.
> 
> (netdev_alloc_frag(), get_page_from_freelist() and put_page() less
> prevalent in perf results)
> 

Oh well, I now remember why I abandoned this : machines dont have
infinite memory after all...

(put_page assumes order-0 page)
