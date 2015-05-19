From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib
 offload on failure to program fib entry in hardware
Date: Tue, 19 May 2015 12:34:18 -0400 (EDT)
Message-ID: <20150519.123418.481170679256206928.davem@davemloft.net>
References: <555A8209.5000306@intel.com>
	<20150518.234839.995695850653714769.davem@davemloft.net>
	<555AD11E.5040709@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873AbbESQeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 12:34:20 -0400
In-Reply-To: <555AD11E.5040709@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Mon, 18 May 2015 22:58:54 -0700

> from where I see, with the limitations on these boxes, this requires
> every app, every `ip route` cmd running on the box to explicitly
> specify offload when running on this hardware.

Users know what they are doing, and will ask for a policy change.

The default should be what happens right now.
