From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next 1/7] net: bluetooth: compact struct bt_skb_cb by inlining struct hci_req_ctrl
Date: Thu, 26 Feb 2015 08:15:05 -0800
Message-ID: <8FC7DD28-25D4-4BB7-AB6F-13FC94E18176@holtmann.org>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com> <1424916612-744-2-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>, willemb@google.com,
	edumazet@google.com, shmulik.ladkani@gmail.com,
	netdev@vger.kernel.org
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:57438 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932243AbbBZQPL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 11:15:11 -0500
In-Reply-To: <1424916612-744-2-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eyal,

> struct hci_req_ctrl is never used outside of struct bt_skb_cb;
> Inlining it frees 8 bytes on a 64 bit system in skb->cb[] allowing
> the addition of more ancillary data.
> 
> Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
> ---
> include/net/bluetooth/bluetooth.h | 10 +++-------
> net/bluetooth/hci_core.c          | 12 ++++++------
> net/bluetooth/hci_event.c         |  4 ++--
> net/bluetooth/hci_request.c       |  6 +++---
> net/bluetooth/hci_sock.c          |  2 +-
> 5 files changed, 15 insertions(+), 19 deletions(-)

it would be a really good idea to actually send this to linux-bluetooth@vger.kernel.org for review.

Regards

Marcel
