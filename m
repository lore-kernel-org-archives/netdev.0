From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next V4 5/6] net: introduce NETDEV_CHANGE_TX_QUEUE_LEN
Date: Thu, 30 Jun 2016 09:33:06 -0700
Message-ID: <577549C2.7010406@gmail.com>
References: <1467269136-8082-1-git-send-email-jasowang@redhat.com>
 <1467269136-8082-6-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	eric.dumazet@gmail.com, brouer@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35740 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbcF3Qdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 12:33:40 -0400
In-Reply-To: <1467269136-8082-6-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-29 11:45 PM, Jason Wang wrote:
> This patch introduces a new event - NETDEV_CHANGE_TX_QUEUE_LEN, this
> will be triggered when tx_queue_len. It could be used by net device
> who want to do some processing at that time. An example is tun who may
> want to resize tx array when tx_queue_len is changed.
> 
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---


Thanks for adding the setlink case.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
