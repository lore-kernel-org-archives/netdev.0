From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH net] udp: consistently apply ufo or fragmentation
Date: Mon, 14 Aug 2017 14:31:39 +0300
Message-ID: <a9b32d53-5b3c-9596-7309-e56e3945a110@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:11065 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752342AbdHNLbu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 07:31:50 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Willem,

ip*_ufo_append_data() is called now for each skb_is_gso() packet.
Before the patch it was called for UDP packets only.

Could you please clarify, is it correct?

Thank you,
	Vasily Averin
