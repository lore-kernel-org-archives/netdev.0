From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: only use connected ports when sending
Date: Thu, 24 Jul 2014 23:31:03 -0700 (PDT)
Message-ID: <20140724.233103.1260773709423863725.davem@davemloft.net>
References: <53D01FD9.5000804@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbaGYGbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 02:31:05 -0400
In-Reply-To: <53D01FD9.5000804@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Wed, 23 Jul 2014 16:49:29 -0400

> The sunvnet driver doesn't check whether or not a port is connected when
> transmitting packets, which results in failures if a port fails to connect
> (e.g., due to a version mismatch). The original code also assumes
> unnecessarily that the first port is up and a switch, even though there is
> a flag for switch ports.
> 
> This patch only matches a port if it is connected, and otherwise uses the
> switch_port flag to send the packet to a switch port that is up.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

This doesn't apply because your email client mangled the patch, it turned
TAB characters into sequences of SPACE characters.

Secondly, this is a bonafide bug fix, and therefore should be targetted
at 'net' instead of 'net-next'.

Thanks.
