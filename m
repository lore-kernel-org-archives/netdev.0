From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3 of 5] xen-netfront: Avoid unaligned accesses to IP	header
Date: Thu, 16 Oct 2008 05:12:38 -0400
Message-ID: <48F70586.10607@garzik.org>
References: <d3d2ad0d95db689f77ab.1224031842@abulafia.goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	NetDev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36054 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755893AbYJPJMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2008 05:12:44 -0400
In-Reply-To: <d3d2ad0d95db689f77ab.1224031842@abulafia.goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeremy Fitzhardinge wrote:
> From: Isaku Yamahata <yamahata@valinux.co.jp>
> 
> Align ip header to a 16 byte boundary to avoid unaligned
> access like other drivers.
> Without this patch, xen-netfront doesn't work well on ia64.
> 
> [ Jeff, this is the only patch in the series which is in your
>   territory. -J ]
> 
> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
> Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
> ---
>  drivers/net/xen-netfront.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)

applied


