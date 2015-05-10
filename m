From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: deinline netif_tx_stop_queue() and
 netif_tx_stop_all_queues()
Date: Sat, 09 May 2015 22:27:45 -0400 (EDT)
Message-ID: <20150509.222745.411555396353592046.davem@davemloft.net>
References: <1430998870-1453-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: dvlasenk@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1430998870-1453-1-git-send-email-dvlasenk@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Thu,  7 May 2015 13:41:10 +0200

> These functions compile to ~60 bytes of machine code each.

As others have suggested, just kill the WARN_ON().
