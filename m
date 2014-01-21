From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 0/2] Bug Fixes for SFC driver
Date: Tue, 21 Jan 2014 18:02:50 +0000
Message-ID: <1390327370.6241.22.camel@bwh-desktop.uk.level5networks.com>
References: <52D98860.4020402@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6413 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754360AbaAUSCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 13:02:55 -0500
In-Reply-To: <52D98860.4020402@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-17 at 19:45 +0000, Shradha Shah wrote:
> I am taking over the upstream patch submission work for the 
> sfc driver from Ben Hutchings.
> 
> These patches are bug fixes to the sfc driver involving 
> replacement of the PORT RESET MC command and fixing transposed 
> ptp_{under,over}size_sync_window_statistics
> 
> The PORT_RESET bug fix is needed for all versions supporting EF10
> i.e all versions including and after 3.12.
> 
> Ben Hutchings (1):
>   sfc: Fix transposed ptp_{under,over}size_sync_windows statistics
> 
> Jon Cooper (1):
>   sfc: Change efx_mcdi_reset_port to use ENTITY_RESET MC command.
> 
>  drivers/net/ethernet/sfc/ef10.c |   31 ++++++++++++++++++++++++++-----
>  drivers/net/ethernet/sfc/mcdi.c |   14 +++++++++++---
>  drivers/net/ethernet/sfc/ptp.c  |    4 ++--
>  3 files changed, 39 insertions(+), 10 deletions(-)

David, I don't know if you're waiting for my ack on these, but in case
you are:

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Shradha will send a MAINTAINERS update in the next patch series.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
