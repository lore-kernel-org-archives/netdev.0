From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ibm_newemac: select CRC32 in Kconfig
Date: Tue, 17 Jun 2008 23:25:47 -0400
Message-ID: <4858803B.7020008@pobox.com>
References: <20080617192755.575dcad4@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40516 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756521AbYFRDZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 23:25:51 -0400
In-Reply-To: <20080617192755.575dcad4@zod.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Josh Boyer wrote:
> The ibm_newemac driver requires ether_crc to be defined.  Apparently it is
> possible to generate a .config without CONFIG_CRC32 set which causes the
> following link errors if IBM_NEW_EMAC is selected:
> 
>   LD      .tmp_vmlinux1
> drivers/built-in.o: In function `emac_hash_mc':
> core.c:(.text+0x2f524): undefined reference to `crc32_le'
> core.c:(.text+0x2f528): undefined reference to `bitrev32'
> make: *** [.tmp_vmlinux1] Error 1
> 
> This patch has IBM_NEW_EMAC select CRC32 so we don't hit this error.
> 
> Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>
> ---
>  drivers/net/ibm_newemac/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

applied


