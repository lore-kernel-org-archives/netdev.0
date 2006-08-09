From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 8/9] [TULIP] Make DS21143 printout match lspci output
Date: Wed, 09 Aug 2006 01:36:27 -0400
Message-ID: <44D9745B.1040609@garzik.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca> <11549840122892-git-send-email-kyle@parisc-linux.org> <11549840321096-git-send-email-kyle@parisc-linux.org> <1154984032324-git-send-email-kyle@parisc-linux.org> <115498403384-git-send-email-kyle@parisc-linux.org> <11549840341728-git-send-email-kyle@parisc-linux.org> <11549840343640-git-send-email-kyle@parisc-linux.org> <11549840351899-git-send-email-kyle@parisc-linux.org> <11549840361794-git-send-email-kyle@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	val_henson@linux.intel.com, akpm@osdl.org,
	Thibaut Varene <varenet@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:10656 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965074AbWHIFga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 01:36:30 -0400
To: Kyle McMartin <kyle@parisc-linux.org>
In-Reply-To: <11549840361794-git-send-email-kyle@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kyle McMartin wrote:
> From: Thibaut Varene <varenet@parisc-linux.org>
> 
> Signed-off-by: Thibaut Varene <varenet@parisc-linux.org>
> Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
> ---
>  drivers/net/tulip/tulip_core.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
> index bdb6698..21eaeb2 100644
> --- a/drivers/net/tulip/tulip_core.c
> +++ b/drivers/net/tulip/tulip_core.c
> @@ -155,7 +155,7 @@ struct tulip_chip_table tulip_tbl[] = {
>  	tulip_media_task },
>  
>    /* DC21142, DC21143 */
> -  { "Digital DS21143 Tulip", 128, 0x0801fbff,
> +  { "Digital DS21142/43 Tulip", 128, 0x0801fbff,
>  	HAS_MII | HAS_MEDIA_TABLE | ALWAYS_CHECK_MII | HAS_ACPI | HAS_NWAY
>  	| HAS_INTR_MITIGATION | HAS_PCI_MWI, tulip_timer, t21142_media_task },

ACK patches 7-8


