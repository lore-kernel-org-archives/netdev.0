From: "Chris Friesen" <cfriesen@nortel.com>
Subject: quick help with bonding?
Date: Thu, 29 Mar 2007 10:14:40 -0600
Message-ID: <460BE5F0.7070606@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, ctindel@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:55748 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932465AbXC2QO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 12:14:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I"m doing some experimenting with a new network driver that receives 
jumbo frames into multiple separate pages that are then joined together 
in a single sk_buff using skb_fill_page_desc().

It behaved fairly well with standard networking, but its behaving 
strangely with bonding added to the mix.

Could someone either point me to the bonding high level design document 
(couldn't find one at the sourceforge project page) or else give me a 
quick overview of the code path followed by an incoming packet when 
bonding is involved?

Thanks,

Chris Friesen
