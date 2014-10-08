From: Eric Wheeler <netdev@lists.ewheeler.net>
Subject: Re: [PATCH net] bna: page allocation during interrupts to use a
 mempool.
Date: Wed, 8 Oct 2014 12:07:59 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1410081207420.16668@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>    <20140929092833.6c2cb7e9@urahara>    <262CB373A6D1F14F9B81E82F74F77D5A4704FAE7@avmb2.qlogic.org>    <alpine.DEB.2.00.1410061850120.5129@ware.dreamhost.com>  
 <1412646735.11091.93.camel@edumazet-glaptop2.roam.corp.google.com>   <alpine.DEB.2.00.1410061956410.7392@ware.dreamhost.com>  <1412651746.11091.98.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.00.1410071746230.3503@ware.dreamhost.com>
 <1412731718.11091.175.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from homie.mail.dreamhost.com ([208.97.132.208]:34018 "EHLO
	homiemail-a9.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751517AbaJHSwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 14:52:21 -0400
In-Reply-To: <1412731718.11091.175.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Oct 2014, Eric Dumazet wrote:

> On Tue, 2014-10-07 at 17:48 -0700, Eric Wheeler wrote:
>
>> Just += unmap->vector.len still did not work (same backtrace), so I've
>> rebuilt with PAGE_SIZE<<2 and so far so good.  I'll let it run all night
>> and see if we get any problems.
>
> Further inspection of the driver told me that unmap->vector.len should
> be 16384 already. (same than PAGE_SIZE << 2)
> (set at line 304, drivers/net/ethernet/brocade/bna/bnad.c)
>
> So you might hit memory fragmentation issues.
>
> Do you have CONFIG_COMPACTION=y in your .config ?

yes.

-e

>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
