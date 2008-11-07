From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [Patch] Establishing more than 64K outgoing TCP connections
Date: Sat, 8 Nov 2008 02:04:00 +0300
Message-ID: <20081107230400.GA28576@ioremap.net>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887B@MBX73.ad2.softcom.biz> <20081107084555.GA13347@ioremap.net> <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887F@MBX73.ad2.softcom.biz> <20081107.115401.214017400.davem@davemloft.net> <241CE5A1B2AFFA4987A663380D74C0BB3FFDA39997@MBX73.ad2.softcom.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yavor Goulishev <yavor@simplifymedia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:47831 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156AbYKGXEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 18:04:04 -0500
Content-Disposition: inline
In-Reply-To: <241CE5A1B2AFFA4987A663380D74C0BB3FFDA39997@MBX73.ad2.softcom.biz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 07, 2008 at 05:37:33PM -0500, Yavor Goulishev (yavor@simplifymedia.com) wrote:
> It is not the entire table. It is O(number_of_local_interfaces).
> In general, if you have more then one interface you either need to flatten the
> ip/port space and have a smart way to access it in O(1) or you have the O(number_of_local_interfaces).
> The case of ANY can be solved with special ANY interface. So you can get O(1) even there, but the space will grow.

As was already pointed, you can use SO_BINDTODEVICE for this purpose.
Next solution you may think of is already implemented as SO_REUSEADDR
socket option.

-- 
	Evgeniy Polyakov
