From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH][BNX2X] round three
Date: Thu, 11 Oct 2007 19:13:21 +0200
Message-ID: <470E59B1.1000807@broadcom.com>
References: <1192038559.29746.127.camel@eliezer>
 <470D2D7E.8080507@broadcom.com>
 <20071010182857.610893a3@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Andy Whitcroft" <apw@shadowen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2519 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752186AbXJKRNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 13:13:40 -0400
In-Reply-To: <20071010182857.610893a3@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[added Andy Whitcroft, who is listed as a CHECKPATCH maintainer]

Stephen Hemminger wrote:
> Minor formatting nits reported by checkpatch.pl script:

Thanks, I Will fix them.


...

> WARNING: no space between function name and open parenthesis '('
> #777: FILE: drivers/net/bnx2x.c:722:
> +	case (RAMROD_CMD_ID_ETH_PORT_SETUP | BNX2X_STATE_OPENING_WAIT4_PORT):
> 
> WARNING: no space between function name and open parenthesis '('
> #782: FILE: drivers/net/bnx2x.c:727:
> +	case (RAMROD_CMD_ID_ETH_HALT | BNX2X_STATE_CLOSING_WAIT4_HALT):
> 
> WARNING: no space between function name and open parenthesis '('
> #788: FILE: drivers/net/bnx2x.c:733:
> +	case (RAMROD_CMD_ID_ETH_PORT_DEL | BNX2X_STATE_CLOSING_WAIT4_DELETE):
> 
> WARNING: no space between function name and open parenthesis '('
> #793: FILE: drivers/net/bnx2x.c:738:
> +	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_OPEN):
> 

These look like false positives

...


> CHECK: spinlock_t definition without comment
> #9486: FILE: drivers/net/bnx2x.h:508:
> +	spinlock_t		spq_lock;  /* Used to serialize slowpath
This one too

...

> ERROR: Macros with complex values should be enclosed in parenthesis
> #21196: FILE: drivers/net/bnx2x_init.h:138:
> +#define INIT_INTERNAL0_MEM_WR(block_bar, block, reg, \
> +			      part, hw, value, off, len) \

Not sure, I think this one is too, but I'm going to rewrite bnx2x_init.h anyway,
this code is going away.

...

Thanks
Eliezer



