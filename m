From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Socket destruction events via netlink
 sock_diag
Date: Mon, 15 Jun 2015 19:49:39 -0700 (PDT)
Message-ID: <20150615.194939.99619876772139652.davem@davemloft.net>
References: <1434381980-20588-1-git-send-email-kraig@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, mleitner@redhat.com,
	stephen@networkplumber.org, ebiederm@xmission.net, tgraf@suug.ch,
	xemul@openvz.org
To: kraig@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43556 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbbFPCtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 22:49:42 -0400
In-Reply-To: <1434381980-20588-1-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>
Date: Mon, 15 Jun 2015 11:26:17 -0400

> This series extends the netlink sock_diag interface to broadcast
> socket information as they are being destroyed.  The current
> interface is poll based and can not be used to retreive information
> about sockets that are destroyed between poll intervals.
> 
> Only inet sockets are broadcast in this implementation, but other
> families could easily be added as needed in the future.
> 
> If this patch set is accepted, a follow-up patch to the ss utility
> in the iproute2 suite will also be submitted.

Series applied, thanks Craig.
