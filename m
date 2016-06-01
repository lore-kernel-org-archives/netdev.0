From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ravb: Add ESF in RCR for enabling
 separation filter
Date: Wed, 01 Jun 2016 16:01:15 -0700 (PDT)
Message-ID: <20160601.160115.1723237636581037081.davem@davemloft.net>
References: <1464717688-28146-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	horms@verge.net.au, magnus.damm@gmail.com,
	linux-renesas-soc@vger.kernel.org
To: ykaneko0929@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbcFAXBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 19:01:17 -0400
In-Reply-To: <1464717688-28146-1-git-send-email-ykaneko0929@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Date: Wed,  1 Jun 2016 03:01:28 +0900

> From: Masaru Nagai <masaru.nagai.vx@renesas.com>
> 
> The H/W manual recommends B'10 or B'11 in a value of the separation
> filtering select bits in the receive configuration register (RCR.ESF).
> When B'10 is set, frames from non-matching streams are discarded.
> When B'11 is set, frames from non-matching streams are processed in
> reception queue 0 (best effort).
> This patch sets B'11 in ESF.
> 
> [ykaneko0929@gmail.com: revised this commit message]
> Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
