From: Kumar Gala <galak@kernel.crashing.org>
Subject: skb's & hw buffer mgmt
Date: Thu, 19 Mar 2009 21:55:18 -0500
Message-ID: <4FC8D5B7-3242-4C9E-BDD8-5026FC1C73F3@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:42922 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758560AbZCTCzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 22:55:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

I remember you point me at code in the Sun neptune driver as an  
example of how to use hw buffer mgmt w/skb's.  I had a few questions  
on how this actually works.

It appears that you allocate a bunch of pages, seed the HW buffer  
manager.  As you receive packets you setup the skb via  
niu_process_rx_pkt()/niu_rx_skb_append().  I'm a little confused about  
how the non-paged data in the skb itself is actually used.  How does  
skb->data actually point to anything meaningful?

It also seems that you don't actually give the page directly back to  
the HW buffer manager when the skb is released (possibly via a skb- 
 >destructor) but just allocate new pages and add these new buffers to  
the HW manager.  Is that correct?  Is there any particular reason to  
do this?

thanks

- k
