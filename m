From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 02/11] ixgbe: Mask off check of frag_off as we only
 want fragment offset
Date: Fri, 12 Apr 2013 14:12:05 -0700
Message-ID: <1365801125.4459.73.camel@edumazet-glaptop>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
	     <1365765866-15741-3-git-send-email-jeffrey.t.kirsher@intel.com>
	     <1365773328.4459.19.camel@edumazet-glaptop>
	    <1365774332.4459.24.camel@edumazet-glaptop> <51683884.2010509@intel.com>
	   <1365785511.4459.46.camel@edumazet-glaptop> <516850E4.8020504@intel.com>
	  <1365792277.4459.67.camel@edumazet-glaptop> <51686AAF.4090105@intel.com>
	 <1365798584.4459.70.camel@edumazet-glaptop> <51687725.5060008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:42527 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402Ab3DLVMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 17:12:08 -0400
Received: by mail-da0-f51.google.com with SMTP id g27so1292712dan.10
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 14:12:07 -0700 (PDT)
In-Reply-To: <51687725.5060008@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 14:05 -0700, Alexander Duyck wrote:

>  The problem right now is if I call __skb_get_poff it will go
> through the portion of that path you didn't call out that does
> skb_copy_bits.

Absolutely not : skb->data_len is 0.

How possibly can you say such things ?

OK I give up with this topic.
