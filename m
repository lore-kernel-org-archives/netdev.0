From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] remove the obsolete xircom_tulip_cb driver
Date: Mon, 11 Feb 2008 10:52:24 -0500
Message-ID: <47B06F38.6070801@pobox.com>
References: <20080128221412.GJ8767@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55129 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754006AbYBKPw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 10:52:26 -0500
In-Reply-To: <20080128221412.GJ8767@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> The xircom_tulip_cb driver has been replaced the xircom_cb driver, and 
> since it depended on BROKEN_ON_SMP it e.g. was no longer present in many 
> distribution kernels.
> 
> This patch therefore removes it.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
>  drivers/net/tulip/Kconfig           |   15 
>  drivers/net/tulip/Makefile          |    1 
>  drivers/net/tulip/xircom_tulip_cb.c | 1726 ----------------------------
>  3 files changed, 1 insertion(+), 1741 deletions(-)

applied to #upstream (2.6.26)

