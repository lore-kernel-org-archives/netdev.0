From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH v2] net: add skb allocation flags to pskb_copy
Date: Mon, 9 Jun 2014 00:44:02 +0200
Message-ID: <20140608224402.GO5219@cpaasch-mac>
References: <098b2d141d2749cf89e3a2552a74a605@UCL-MBX03.OASIS.UCLOUVAIN.BE>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Arvid Brodin <arvid.brodin@alten.se>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: Octavian Purdila <octavian.purdila@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:50106 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbaFHWoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 18:44:10 -0400
Content-Disposition: inline
In-Reply-To: <098b2d141d2749cf89e3a2552a74a605@UCL-MBX03.OASIS.UCLOUVAIN.BE>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/14 - 20:56:18, Octavian Purdila wrote:
> There are several instances where a pskb_copy or __pskb_copy is
> immediately followed by an skb_clone. Add a new parameter to allow the
> skb to be allocated from the fclone cache and thus speed up subsequent
> skb_clone calls.
> 
> Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
> Cc: Marek Lindner <mareklindner@neomailbox.ch>
> Cc: Simon Wunderlich <sw@simonwunderlich.de>
> Cc: Antonio Quartulli <antonio@meshcoding.com>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Cc: Gustavo Padovan <gustavo@padovan.org>
> Cc: Johan Hedberg <johan.hedberg@gmail.com>
> Cc: Arvid Brodin <arvid.brodin@alten.se>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
> Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
> Cc: Samuel Ortiz <sameo@linux.intel.com>
> Cc: Jon Maloy <jon.maloy@ericsson.com>
> Cc: Allan Stephens <allan.stephens@windriver.com>
> Cc: Andrew Hendry <andrew.hendry@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> 
> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
> ---
>  drivers/net/ieee802154/fakelb.c        | 2 +-
>  include/linux/skbuff.h                 | 8 ++++----
>  net/batman-adv/distributed-arp-table.c | 2 +-
>  net/batman-adv/network-coding.c        | 2 +-
>  net/bluetooth/hci_sock.c               | 5 +++--
>  net/core/skbuff.c                      | 9 ++++++---
>  net/hsr/hsr_device.c                   | 2 +-
>  net/hsr/hsr_main.c                     | 2 +-
>  net/ipv4/tcp_output.c                  | 6 +++---
>  net/netfilter/xt_TEE.c                 | 4 ++--
>  net/nfc/llcp_core.c                    | 2 +-
>  net/nfc/rawsock.c                      | 2 +-
>  net/tipc/bcast.c                       | 2 +-
>  net/x25/x25_forward.c                  | 4 ++--
>  14 files changed, 28 insertions(+), 24 deletions(-)

Reviewed-by: Christoph Paasch <christoph.paasch@uclouvain.be>


Cheers,
Christoph
