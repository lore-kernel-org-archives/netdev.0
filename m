From: Ben Greear <greearb@candelatech.com>
Subject: How to best consolidate list of skbs (msdu) for receive?
Date: Thu, 27 Feb 2014 10:36:30 -0800
Message-ID: <530F85AE.8060002@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48754 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbaB0Sgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 13:36:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ath10k, it can receive msdu (in rx raw mode, at least).  These show up
as a list of skb.  Currently they are just dropped as un-handled, and I
need to fix this.

I think I need to consolidate this list into a single skb in order to pass
it up the stack.

What is the preferred way to go about doing this?

It seems I could just expand the head skb (pskb_expand_head) and copy the data from the others
onto the end of the head skb, but maybe there is a more efficient way to go about
doing this?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
