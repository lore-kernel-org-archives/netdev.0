From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] net-packet: restore packet statistics tp_packets
 to include drops
Date: Mon, 19 Aug 2013 22:22:18 +0400
Message-ID: <5212625A.1090704@cogentembedded.com>
References: <1376855916-21824-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dborkman@redhat.com, netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:40070 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908Ab3HSSWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 14:22:19 -0400
Received: by mail-la0-f53.google.com with SMTP id el20so3523358lab.26
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 11:22:16 -0700 (PDT)
In-Reply-To: <1376855916-21824-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/18/2013 11:58 PM, Willem de Bruijn wrote:

> getsockopt PACKET_STATISTICS returns tp_packets + tp_drops.
> Commit ee80fbf301 cleaned up the getsockopt PACKET_STATISTICS code.

    Please also specify that commit's summary in parens.

> This also changed semantics. Historically, tp_packets included
> tp_drops on return. The commit removed the line that adds tp_drops
> into tp_packets.

> This patch reinstates the old semantics.

> Signed-off-by: Willem de Bruijn <willemb@google.com>

WBR, Sergei
