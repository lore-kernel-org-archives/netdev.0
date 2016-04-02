From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH 0/5] Add driver bpf hook for early packet drop
Date: Sat, 02 Apr 2016 20:41:31 +0200
Message-ID: <1459622491.18188.6.camel@sipsolutions.net>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	 (sfid-20160402_032232_679299_96A5CF41)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, gerlitz@mellanox.com,
	daniel@iogearbox.net, john.fastabend@gmail.com, brouer@redhat.com,
	Lorenzo Colitti <lorenzo@google.com>
To: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58731 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574AbcDBSle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2016 14:41:34 -0400
In-Reply-To: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com> (sfid-20160402_032232_679299_96A5CF41)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 18:21 -0700, Brenden Blanco wrote:
> This patch set introduces new infrastructure for programmatically
> processing packets in the earliest stages of rx, as part of an effort
> others are calling Express Data Path (XDP) [1]. Start this effort by
> introducing a new bpf program type for early packet filtering, before
> even
> an skb has been allocated.
> 
> With this, hope to enable line rate filtering, with this initial
> implementation providing drop/allow action only.

Since this is handed to the driver in some way, I assume the API would
also allow offloading the program to the NIC itself, and as such be
useful for what Android wants to do to save power in wireless?

johannes
