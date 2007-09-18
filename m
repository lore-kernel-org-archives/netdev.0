From: lepton <ytht.net@gmail.com>
Subject: Re: [PATCH] 2.6.22.6 NETWORKING [IPV4]: Always use source addr in skb to reply packet
Date: Tue, 18 Sep 2007 10:59:19 +0800
Message-ID: <20070918025919.GA16136@router.lepton.home>
References: <20070918021617.GA15540@router.lepton.home> <20070917.192044.48396034.davem@davemloft.net> <20070918.112644.28694997.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ytht.net@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:8786 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbXIRDAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 23:00:12 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1476871rvb
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 20:00:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070918.112644.28694997.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
  sorry for my previous email.
  What I mean is icmp_reply and ip_send_reply
in some situation will send out packets with wrong 
DESTINATION address.  the source address is always
correct.
