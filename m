From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/3 net-2.6.26] ip_options_compile cleanup
Date: Wed, 19 Mar 2008 15:41:48 +0300
Message-ID: <1205930508.24116.14.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19048 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756056AbYCSTeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2008 15:34:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches has been originally sent to to netdev@ two weeks
ago.

The idea is the following: ip_options->is_data field is checked only
inside ip_options_compile when opt != NULL. This is possible only on the
following codepath:
    ip_options_get_finish
        opt->is_data = 1;
        ip_options_compile(opt, NULL)

ip_options->is_data is not a part of user<->kernel interface and can be
removed.

Regards,
	Den

