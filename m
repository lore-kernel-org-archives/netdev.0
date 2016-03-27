From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: fix software timestamping
Date: Sun, 27 Mar 2016 15:50:27 +0300
Message-ID: <56F7D713.3060208@cogentembedded.com>
References: <1459074122-6964-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:35417 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbcC0Muc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 08:50:32 -0400
Received: by mail-lf0-f53.google.com with SMTP id q73so76021993lfe.2
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 05:50:31 -0700 (PDT)
In-Reply-To: <1459074122-6964-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/27/2016 01:22 PM, Lino Sanfilippo wrote:

> In ravb_start_xmit dont call skb_tx_timestamp only when hardware
> timestamping is requested: in the latter case software timestamps are
> suppressed and thus the call of skb_tx_timestamp does not have any effect.
>
> Instead call skb_tx_timestamp unconditionally in ravb_start_xmit, since
> the function checks itself if software timestamping is required or should
> be skipped due to hardware timestamping.
>
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
