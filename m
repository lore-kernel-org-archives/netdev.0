From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: 6lowpan: lockless tx queue of routing netlink device
Date: Mon, 10 Feb 2014 20:31:44 +0100
Message-ID: <20140210193142.GA17018@omega>
References: <20140209102047.GA14770@omega>
 <1391949707.10160.130.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140210173314.GA12594@omega>
 <1392056186.6615.40.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140210182138.GB15674@omega>
 <1392060372.6615.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:44525 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbaBJTbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 14:31:51 -0500
Received: by mail-ea0-f174.google.com with SMTP id b10so3213496eae.19
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 11:31:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1392060372.6615.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 11:26:12AM -0800, Eric Dumazet wrote:
> On Mon, 2014-02-10 at 19:21 +0100, Alexander Aring wrote:
> 
> > no problem. Maybe you can try to give me some explanation what you did
> > there?
> > 
> > I see you make a lockdep_set_class for each tx queue and assign the 
> > lowpan_netdev_xmit_lock_key. So why it's better to make a own
> > "lock_key".
> 
> This will be explained in the patch I'll cook.
> 
Okay, then you can add a

Tested-by: Alexander Aring <alex.aring@gmail.com>

Thanks!

- Alex
