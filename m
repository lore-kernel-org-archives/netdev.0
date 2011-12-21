From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH] rps: fix insufficient bounds checking in store_rps_dev_flow_table_cnt()
Date: Wed, 21 Dec 2011 18:41:36 -0500
Message-ID: <F4C37D6F-743C-4A24-A5EB-E0E2B529FA3B@gmail.com>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com> <1324495344.2621.5.camel@edumazet-laptop> <20111221.144126.2213051521357190879.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34799 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557Ab1LUXln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 18:41:43 -0500
Received: by iaeh11 with SMTP id h11so12577492iae.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 15:41:43 -0800 (PST)
In-Reply-To: <20111221.144126.2213051521357190879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Agreed too. ;-)  Thanks for the suggestion.

I will do a v2 without using the magic number.

BTW, a similar magic number (1<<30) is used in rps_sock_flow_sysctl()
at net/core/sysctl_net_core.c.  I will change that as well.

- xi
