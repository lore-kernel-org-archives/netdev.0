From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: TSO support
Date: Tue, 27 Sep 2011 17:00:44 +0900
Message-ID: <9E843B57-78E9-43E1-8963-ABBF841CF318@sfc.wide.ad.jp>
References: <CAG+4w0mNdSwwQMH7+DSGUzMUrqjE_v7M55EP8Ug6JxytuJsN7g@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1244.3)
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Sedat Cakir <sedat.cakirim@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:57738 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751172Ab1I0IHQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 04:07:16 -0400
In-Reply-To: <CAG+4w0mNdSwwQMH7+DSGUzMUrqjE_v7M55EP8Ug6JxytuJsN7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

On TSO and TCP options, as far as I tested approx. 10 NICs, TSO copies TCP options to all the split segments. (We performed this test for Timestamp and an undefined option).  
This paper (http://nrg.cs.ucl.ac.uk/mjh/tmp/mboxes.pdf) would be helpful.  

Thanks,
- Michio

On Sep 27, 2011, at 4:19 PM, Sedat Cakir wrote:

> Hi,
> 
> We are adding the TCP Segmentation offload (TSO) support to the device
> driver and the hardware. I am wondering: Can Linux subsystem supports
> the use of IP options and TCP options? If so then which options (e.g
> SACK processing for TCP)? Do we need any implementation in the NIC to
> manage TCP/IP options?
> 
> Thanks,
> Sedat
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
