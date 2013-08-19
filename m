From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] packet: restore packet statistics tp_packets to include
 drops
Date: Mon, 19 Aug 2013 23:11:08 +0200
Message-ID: <521289EC.40703@redhat.com>
References: <5212625A.1090704@cogentembedded.com> <1376944822-30454-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925Ab3HSVLN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 17:11:13 -0400
In-Reply-To: <1376944822-30454-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2013 10:40 PM, Willem de Bruijn wrote:
> getsockopt PACKET_STATISTICS returns tp_packets + tp_drops. Commit
> ee80fbf301 ("packet: account statistics only in tpacket_stats_u")
> cleaned up the getsockopt PACKET_STATISTICS code.
> This also changed semantics. Historically, tp_packets included
> tp_drops on return. The commit removed the line that adds tp_drops
> into tp_packets.
>
> This patch reinstates the old semantics.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
