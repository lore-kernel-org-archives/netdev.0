From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/3] Simplified 16 bit Toeplitz hash algorithm
Date: Mon, 03 Jan 2011 11:54:21 -0800 (PST)
Message-ID: <20110103.115421.232753837.davem@davemloft.net>
References: <20110103.110244.183045594.davem@davemloft.net>
	<1294083039.3167.184.camel@localhost>
	<4D2228E0.9030908@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, therbert@google.com,
	netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60349
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753621Ab1ACTxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 14:53:50 -0500
In-Reply-To: <4D2228E0.9030908@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 03 Jan 2011 11:52:00 -0800

> Since the approach is based on Toeplitz it can be applied to all
> hardware capable of generating a Toeplitz based hash and as a result
> it would likely also work in a much more vendor neutral kind of way
> than Flow Director currently does.

Immediately this excludes NIU, for one, since it does not use Topelitz.
