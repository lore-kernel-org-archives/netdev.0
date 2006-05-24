From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [resend PATCH 1/1] b44: fix ethool link settings support
Date: Wed, 24 May 2006 02:41:18 -0400
Message-ID: <4474000E.6070804@pobox.com>
References: <1146065509.28067.52.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:64737 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932612AbWEXGlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 02:41:21 -0400
To: Gary Zambrano <zambrano@broadcom.com>
In-Reply-To: <1146065509.28067.52.camel@dhcp-10-7-81-7.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gary Zambrano wrote:
> +		if (cmd->advertising & ADVERTISE_ALL) {
> +			if (cmd->advertising & ADVERTISE_10HALF)
> +				bp->flags |= B44_FLAG_ADV_10HALF;
> +			if (cmd->advertising & ADVERTISE_10FULL)
> +				bp->flags |= B44_FLAG_ADV_10FULL;
> +			if (cmd->advertising & ADVERTISE_100HALF)
> +				bp->flags |= B44_FLAG_ADV_100HALF;
> +			if (cmd->advertising & ADVERTISE_100FULL)
> +				bp->flags |= B44_FLAG_ADV_100FULL;
> +		} else {
> +			bp->flags |= (B44_FLAG_ADV_10HALF |
> +				      B44_FLAG_ADV_10FULL |
> +				      B44_FLAG_ADV_100HALF |
> +				      B44_FLAG_ADV_100FULL);
> +		}

The logic above is backwards.  I presume the first test should be
	if (!(cmd->advertising & ADVERTISE_ALL))

The rest looks OK.

	Jeff


