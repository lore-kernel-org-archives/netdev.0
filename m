From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [PATCH 3/3] rx_all e100 patch
Date: Tue, 25 Nov 2003 17:56:11 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125175611.A1506@sygehus.dk>
References: <3FC30AEE.7000005@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3FC30AEE.7000005@candelatech.com>; from greearb@candelatech.com on Mon, Nov 24, 2003 at 11:55:26PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2003 at 11:55:26PM -0800, Ben Greear wrote:

> +		/* Discard over-runs */
> +		if (bdp->config[6] & CB_CFIG_SAVE_OVERRUNS) {
> +			bdp->config[6] &= !CB_CFIG_SAVE_OVERRUNS;
> +			E100_CONFIG(bdp, 6);
>  		}
> -	}
> +
> +		/* Don't send CRC (FCS) to memory */
> +		if (bdp->config[18] & CB_CFIG_CRC_IN_MEM) {
> +			bdp->config[18] &= !CB_CFIG_CRC_IN_MEM;
> +			E100_CONFIG(bdp, 18);
> +		}
> +        }

I think you want ~CB_CFIG_XXX instead of !CB_CFIG_XXX.

-- 
Regards,
Rask Ingemann Lambertsen
