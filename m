From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [8/15] libertas_tf: if_usb.c: don't export static symbol
Date: Fri, 13 Mar 2015 14:18:38 +0000 (UTC)
Message-ID: <20150313141838.B883D1416F4@smtp.codeaurora.org>
References: <1426092997-30605-9-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	daniel@iogearbox.net
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52062 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbbCMOSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 10:18:39 -0400
In-Reply-To: <1426092997-30605-9-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> The semantic patch that fixes this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @r@
> type T;
> identifier f;
> @@
> 
> static T f (...) { ... }
> 
> @@
> identifier r.f;
> declarer name EXPORT_SYMBOL_GPL;
> @@
> 
> -EXPORT_SYMBOL_GPL(f);
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
