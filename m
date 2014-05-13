From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next 3/5] ieee802154: change _cb
 handling slightly
Date: Tue, 13 May 2014 16:25:07 -0300
Message-ID: <20140513192507.GA12817@ws>
References: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
 <1400001846-5349-4-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.almesberger.net ([204.10.140.10]:50768 "EHLO
	host.almesberger.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708AbaEMTZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 15:25:30 -0400
Content-Disposition: inline
In-Reply-To: <1400001846-5349-4-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phoebe Buckheister wrote:
> +static inline struct ieee802154_mac_cb *mac_cb_alloc(struct sk_buff *skb)

That's a rather misleading name for a mere initialization.
How about mac_cb_init ?

The rest of this patch looks nice.

- Werner
