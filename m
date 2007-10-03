From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.24 0/3]: More TCP fixes
Date: Wed,  3 Oct 2007 14:00:15 +0300
Message-ID: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Cedric Le Goater <legoater@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45061 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906AbXJCLAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 07:00:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Sacktag fastpath_cnt_hint seems to be very tricky to get right...
I suppose this one fixes Cedric's case. I cannot say for sure    
until there is something more definite indication of
tcp_retrans_try_collapse origin than what the simple late WARN_ON
gave for us. ...Especially since it's non-trivial to have skb
hint "correctly" positioned in the write_queue while still ending
up calling that function. However, considering how difficult it
seems to be for Cedric to reproduce, it might well be this one.

In addition, I noticed another reset which wasn't previously   
converted to WARN_ON, so doing that now. Boot + simple xfer
tested. Please apply to net-2.6.24.

--
 i.


