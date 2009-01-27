From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Tue, 27 Jan 2009 09:20:17 -0800 (PST)
Message-ID: <20090127.092017.40699485.davem@davemloft.net>
References: <20090126195930.GA28208@hmsreliant.think-freely.org>
	<20090127171857.GB14429@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42697
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753255AbZA0RUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 12:20:20 -0500
In-Reply-To: <20090127171857.GB14429@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 27 Jan 2009 12:18:57 -0500

> Do we now have lttng in linux-next?  Otherwise these trace point would
> be useless there without more patching.

We're merging this stuff to solve the chicken and egg
problem wherein the lttng tree merge is basically
stalled.

If the individual subsystem annotations go in, the hope
is that they'll have less to merge and thus it's more likely
to actually happen.
