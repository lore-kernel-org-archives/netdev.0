From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] xen-netback: clear vif->task on disconnect
Date: Tue, 03 Dec 2013 16:23:30 +0400
Message-ID: <529DCD42.4070702@cogentembedded.com>
References: <1386064427-31008-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>, xen-devel@lists.xen.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:45090 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380Ab3LCMXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 07:23:51 -0500
Received: by mail-lb0-f180.google.com with SMTP id w6so8705420lbh.39
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 04:23:49 -0800 (PST)
In-Reply-To: <1386064427-31008-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03-12-2013 13:53, Paul Durrant wrote:

> xenvif_start_xmit() relies on checking vif->task for NULL to determine
> whether the vif is ready to accept packets. The task thread is stopped in
> xenvif_disconnect() but task is not set to NULL. Thus, on a re-connect the
> check will give a false positive.
> Also since commit ea732dff5cfa10789007bf4a5b935388a0bb2a8f it should not

    Please also specify that commit's summary line in parens.

> be possible for xenvif_connect() to be called if the vif is already connected
> so change the check of vif->tx_irq to a BUG_ON() and also add a
> BUG_ON(vif->task).

> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>

WBR, Sergei
