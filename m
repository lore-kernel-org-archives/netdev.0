From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] via-velocity: Correct setting of skipped checksums
Date: Fri, 20 Nov 2009 09:36:06 -0800 (PST)
Message-ID: <20091120.093606.75426775.davem@davemloft.net>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091120161205.6ddeb3ff@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: simon.kagstrom@netinsight.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58679
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754190AbZKTRft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:35:49 -0500
In-Reply-To: <20091120161205.6ddeb3ff@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Fri, 20 Nov 2009 16:12:05 +0100

> (Taken from the VIA driver). Check that this is actually an UDP or TCP
> packet before claiming that the checksum is unnecessary.
> 
> Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>

Why would the chip specifically say UDP or TCP checksum is OK
on a packet that is not of said protocol type?

Just wondering...
