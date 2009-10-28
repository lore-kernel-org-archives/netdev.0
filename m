From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH 01/23] igb: add support for seperate
 tx-usecs setting in ethtool
Date: Wed, 28 Oct 2009 08:42:07 -0700
Message-ID: <20091028084207.1c504084@nehalam>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
	<20091028.033922.99548522.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55253 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754504AbZJ1PmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 11:42:09 -0400
In-Reply-To: <20091028.033922.99548522.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Oct 2009 03:39:22 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> +	new_rx_count = max(new_rx_count, (u32)IGB_MIN_RXD);

new_rx_count = max_t(u32, new_rx_count, IGB_MIN_RXD)
  is slightly cleaner (hides cast)

-- 
