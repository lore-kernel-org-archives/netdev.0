From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: restore packet statistics tp_packets to
 include drops
Date: Tue, 20 Aug 2013 17:24:37 -0700 (PDT)
Message-ID: <20130820.172437.2089717645078465295.davem@davemloft.net>
References: <5212625A.1090704@cogentembedded.com>
	<1376944822-30454-1-git-send-email-willemb@google.com>
	<521289EC.40703@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816Ab3HUAYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 20:24:38 -0400
In-Reply-To: <521289EC.40703@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 19 Aug 2013 23:11:08 +0200

> On 08/19/2013 10:40 PM, Willem de Bruijn wrote:
>> getsockopt PACKET_STATISTICS returns tp_packets + tp_drops. Commit
>> ee80fbf301 ("packet: account statistics only in tpacket_stats_u")
>> cleaned up the getsockopt PACKET_STATISTICS code.
>> This also changed semantics. Historically, tp_packets included
>> tp_drops on return. The commit removed the line that adds tp_drops
>> into tp_packets.
>>
>> This patch reinstates the old semantics.
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
> 
> Acked-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.
