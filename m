From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net-packet: restore packet statistics tp_packets
 to include drops
Date: Mon, 19 Aug 2013 08:53:54 +0200
Message-ID: <5211C102.9090908@redhat.com>
References: <1376855916-21824-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21187 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007Ab3HSGx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:53:59 -0400
In-Reply-To: <1376855916-21824-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2013 09:58 PM, Willem de Bruijn wrote:
> getsockopt PACKET_STATISTICS returns tp_packets + tp_drops.
> Commit ee80fbf301 cleaned up the getsockopt PACKET_STATISTICS code.
> This also changed semantics. Historically, tp_packets included
> tp_drops on return. The commit removed the line that adds tp_drops
> into tp_packets.
>
> This patch reinstates the old semantics.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
