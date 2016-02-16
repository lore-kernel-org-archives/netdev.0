From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Tue, 16 Feb 2016 15:45:55 -0500 (EST)
Message-ID: <20160216.154555.1807667652677383104.davem@davemloft.net>
References: <20160216.144759.1984502562641417028.davem@davemloft.net>
	<CAEh+42jbaryH8J4vZYXM0yVQcaXZ23Q59_iHr8QT_2PHRmDGgg@mail.gmail.com>
	<20160216.154004.1823575040012545784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, pabeni@redhat.com, netdev@vger.kernel.org,
	pshelar@nicira.com, tgraf@suug.ch
To: jesse@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbcBPUp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:45:57 -0500
In-Reply-To: <20160216.154004.1823575040012545784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 16 Feb 2016 15:40:04 -0500 (EST)

> Oh yes, I'm mixing different parts of the conversation.  We must
> accept on RX zero checksum fields even for ipv6 because of the way the
> VXLAN RFC is worded, correct.

Paolo, can you please respin your patch against 'net'?  I get rejects.
