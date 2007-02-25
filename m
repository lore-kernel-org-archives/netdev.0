From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH][XFRM_TUNNEL]: Reload header pointer after pskb_may_pull/pskb_expand_head
Date: Sat, 24 Feb 2007 23:47:58 -0200
Message-ID: <39e6f6c70702241747l19dd1b21l9a28f7d6f64a4a6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:32525 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933618AbXBYBr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 20:47:59 -0500
Received: by wr-out-0506.google.com with SMTP id 71so11266wri
        for <netdev@vger.kernel.org>; Sat, 24 Feb 2007 17:47:59 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

           Please consider applying, this was found on your latest
net-2.6 tree while playing around with that ip_hdr() + turn
skb->nh/h/mac pointers  as offsets on 64 bits idea :-)

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Regards,

- Arnaldo
