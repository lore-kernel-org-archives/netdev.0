From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: bna alloc_pages() order 2 failure in bnad.c
 bnad_rxq_refill_page()
Date: Mon, 29 Sep 2014 09:28:33 -0700
Message-ID: <20140929092833.6c2cb7e9@urahara>
References: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com
To: Eric Wheeler <nevdev@lists.ewheeler.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:65216 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236AbaI2Q2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 12:28:46 -0400
Received: by mail-pa0-f41.google.com with SMTP id eu11so2399776pac.28
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 09:28:46 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 27 Sep 2014 16:44:22 -0700 (PDT)
Eric Wheeler <nevdev@lists.ewheeler.net> wrote:

> Hello all,
> 
> We're using the 10gbe bna card and sometimes we get pages and pages of 
> alloc_pages() failure backtraces like below.  (The maintainer 
> rmody@brocade.com does not appear to have an active email at brocade, but 
> cc'ing again just in case.)
> 
> It looks like bnad_rxq_refill_page() in bnad.c is allocating for the 
> receive queue but fails.  We've already tried bumping vm.min_free_kbytes 
> and vm.zone_reclaim_mode but it doesn't appear to help.
> 
> Suggestions?
> 
> Would it be appropriate to convert alloc_pages() to a mempool 
> implementation?
> 
> -Eric

Brocade sold the NIC hardware business off to Qlogic.
I told them to update MAINTAINERS but they haven't submitted a patch yet.
