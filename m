From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 0/2] Reduce the number of skb->data direct accesses
Date: Tue, 27 Mar 2007 16:41:11 -0300
Message-ID: <20070327194111.GA20303@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:23799 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbXC0Tle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 15:41:34 -0400
Received: by wx-out-0506.google.com with SMTP id h31so2590963wxd
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 12:41:33 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

	Reworked the patches to not use skb_copy_bits, but some new accessors,
namely skb_copy_from_linear_data{_offset}().

        Please consider pulling from the usual place:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22

Best Regards,

- Arnaldo
