From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH net-next] packet: move hw/sw timestamp extraction into
 a small helper
Date: Mon, 15 Apr 2013 16:28:38 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1304151626550.27514@ask.diku.dk>
References: <cover.1366022623.git.dborkman@redhat.com>
 <45719bcd37c3f11eea24c2a72c09abd9907a5072.1366022623.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:35900 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022Ab3DOPA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 11:00:26 -0400
In-Reply-To: <45719bcd37c3f11eea24c2a72c09abd9907a5072.1366022623.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Apr 2013, Daniel Borkmann wrote:

> This patch introduces a small helper function, that is used by AF_PACKET.
> Based on the flags that are passed, it extracts the packet timestamp in
> the receive path. This is merely a refactoring to remove some duplicate
> code in tpacket_rcv(), make it more readable, and to enable others to use
> this function as well.
>
> Cc: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
> include/linux/skbuff.h | 20 ++++++++++++++++++++
> net/packet/af_packet.c | 38 ++++----------------------------------
> 2 files changed, 24 insertions(+), 34 deletions(-)

Nice consolidation, good work Daniel :-)

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
