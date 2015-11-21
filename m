From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] packet: Allow packets with only a header (but no payload)
Date: Sun, 22 Nov 2015 00:32:12 +0300
Message-ID: <5650E2DC.9060800@cogentembedded.com>
References: <1437495247-471-1-git-send-email-martin.blumenstingl@googlemail.com>
 <1448067012-15090-1-git-send-email-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, edumazet@google.com, dborkman@redhat.com,
	davem@davemloft.net, mostrows@earthlink.net, nbd@openwrt.org
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35868 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbbKUVcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 16:32:15 -0500
Received: by lbblt2 with SMTP id lt2so78948324lbb.3
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 13:32:14 -0800 (PST)
In-Reply-To: <1448067012-15090-1-git-send-email-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/21/2015 3:50 AM, Martin Blumenstingl wrote:

> 9c70776 added validation for the packet size in packet_snd. This change

    Please run your patch thru scripts/checkpatch.pl -- it now enforces 
certain commit citing style.

> enforced that every packet needs a header with at least hard_header_len
> bytes  and at least one byte payload.
>
> This fixes PPPoE connections which do not have a "Service" or
> "Host-Uniq" configured (which is violating the spec, but is still
> widely used in real-world setups). Those are currently failing with the
> following message: "pppd: packet size is too short (24 <= 24)"
>
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>

[...]

MBR, Sergei
