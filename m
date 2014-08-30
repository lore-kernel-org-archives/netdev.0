From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Fri, 29 Aug 2014 20:22:10 -0700 (PDT)
Message-ID: <20140829.202210.1424256004723217664.davem@davemloft.net>
References: <1409142672.26515.24.camel@localhost>
	<20140827.134510.2172564669938048576.davem@davemloft.net>
	<1409190174.27664.10.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com, brouer@redhat.com,
	john.r.fastabend@intel.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbaH3DWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 23:22:11 -0400
In-Reply-To: <1409190174.27664.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 28 Aug 2014 03:42:54 +0200

> I wonder if we still might need a separate call for tx_flush, e.g. for
> af_packet if one wants to allow user space control of batching, MSG_MORE
> with tx hangcheck (also in case user space has control over it) or
> implement TCP_CORK alike option in af_packet.

I disagree with allowing the user to hold a device TX queue hostage
across system calls, therefore the user should provide the entire
batch in such a case.
