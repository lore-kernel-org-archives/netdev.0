From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: dsa: b53: constify xfrm_replay structures
Date: Tue, 9 Aug 2016 10:23:16 -0700
Message-ID: <4a13be00-d6ac-2c40-b7a6-1436072d36b8@gmail.com>
References: <1470761889-26808-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34080 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbcHIRXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 13:23:18 -0400
In-Reply-To: <1470761889-26808-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2016 09:58 AM, Julia Lawall wrote:
> The xfrm_replay structures are never modified, so declare them as const.

You mean b53_io_ops here, right? Other than that LTGM, but this will
have to wait for "net"next to re_open since this is more of a cleanup
than bugfix. Thanks!
-- 
Florian
