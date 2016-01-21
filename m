From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key (v3)
Date: Wed, 20 Jan 2016 20:05:29 -0800
Message-ID: <24100.1453349129@famine>
References: <1453267933-25381-1-git-send-email-wen.gang.wang@oracle.com> <569F2806.70608@gmail.com> <569F397B.7010808@oracle.com> <569F3D19.8020307@gmail.com> <569F579F.1060708@oracle.com> <569F59D8.2060200@gmail.com> <56A04522.9010300@oracle.com>
Cc: zhuyj <zyjzyj2000@gmail.com>, netdev@vger.kernel.org
To: Wengang Wang <wen.gang.wang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:41831 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbcAUEFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 23:05:33 -0500
In-reply-to: <56A04522.9010300@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wengang Wang <wen.gang.wang@oracle.com> wrote:
[...]
>For ipip,  yes seems update_pmtu is called in line for each call of
>queue_xmit.  Do you know if it's a good configuration for ipip + bonding?

	Yes, it is.

>Other's comment and suggestion?

	I agree with Sabrina Dubroca <sd@queasysnail.net>'s suggestions
from yesterday.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
