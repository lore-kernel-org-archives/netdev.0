From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 6lowpan: lockless tx queue of routing netlink device
Date: Mon, 10 Feb 2014 11:26:12 -0800
Message-ID: <1392060372.6615.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140209102047.GA14770@omega>
	 <1391949707.10160.130.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140210173314.GA12594@omega>
	 <1392056186.6615.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140210182138.GB15674@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:47593 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaBJT0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 14:26:14 -0500
Received: by mail-pb0-f51.google.com with SMTP id un15so6676588pbc.10
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 11:26:14 -0800 (PST)
In-Reply-To: <20140210182138.GB15674@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-10 at 19:21 +0100, Alexander Aring wrote:

> no problem. Maybe you can try to give me some explanation what you did
> there?
> 
> I see you make a lockdep_set_class for each tx queue and assign the 
> lowpan_netdev_xmit_lock_key. So why it's better to make a own
> "lock_key".

This will be explained in the patch I'll cook.
