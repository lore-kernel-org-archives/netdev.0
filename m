From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] solos: Add 'Firmware' attribute for Traverse
 overall firmware version
Date: Mon, 1 Nov 2010 16:49:38 -0400
Message-ID: <20101101164938.5807e4c3@s6510>
References: <1288643669.5977.21.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53323 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754171Ab0KAUto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 16:49:44 -0400
In-Reply-To: <1288643669.5977.21.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Nov 2010 16:34:29 -0400
David Woodhouse <dwmw2@infradead.org> wrote:

> The existing 'FirmwareVersion' attribute only covers the DSP firmware as
> provided by Conexant; not the overall version of the device firmware. We
> do want to be able to see the full version number too.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> ---
>  drivers/atm/solos-attrlist.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/atm/solos-attrlist.c b/drivers/atm/solos-attrlist.c
> index 1a9332e..9a676ee 100644
> --- a/drivers/atm/solos-attrlist.c
> +++ b/drivers/atm/solos-attrlist.c
> @@ -1,6 +1,7 @@
>  SOLOS_ATTR_RO(DriverVersion)
>  SOLOS_ATTR_RO(APIVersion)
>  SOLOS_ATTR_RO(FirmwareVersion)
> +SOLOS_ATTR_RO(Version)
>  // SOLOS_ATTR_RO(DspVersion)
>  // SOLOS_ATTR_RO(CommonHandshake)
>  SOLOS_ATTR_RO(Connected)

There is a firware version in ethtool, does this driver supply it?
