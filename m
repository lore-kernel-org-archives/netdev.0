From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1] net: fix and typo's
Date: Fri, 26 Oct 2007 13:06:13 -0700
Message-ID: <472248B5.1020704@intel.com>
References: <47221EBE.3070109@tiscali.nl> <47222932.80408@intel.com> <4722460E.4010201@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
To: Roel Kluin <12o3l@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19908 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752949AbXJZUKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 16:10:43 -0400
In-Reply-To: <4722460E.4010201@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roel Kluin wrote:
> Kok, Auke wrote:
> 
>> Ack this e1000e change here!
> 
>> (PS since there was only 1 netdriver patch here and the rest is wireless, I would
>> have suggested splitting this patch up in two and sending them to the wireless
>> maintainer and netdevice maintainer separately. But I'm sure this will get picked
>> up anyway.)
> 
> Ok, I've split the patch and sent the rest to wireless. Here's this single fix again
> you acked.

OK, bedankt Roel!

I'll forward this to Jeff for merging.

Cheers,

Auke



> --
>         Fix priority mistakes similar to '!x & y'
>     
>         Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> ---
> diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
> index cf70522..14141a5 100644
> --- a/drivers/net/e1000e/82571.c
> +++ b/drivers/net/e1000e/82571.c
> @@ -283,7 +283,7 @@ static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
>  			adapter->flags &= ~FLAG_HAS_WOL;
>  		/* quad ports only support WoL on port A */
>  		if (adapter->flags & FLAG_IS_QUAD_PORT &&
> -		    (!adapter->flags & FLAG_IS_QUAD_PORT_A))
> +		    (!(adapter->flags & FLAG_IS_QUAD_PORT_A)))
>  			adapter->flags &= ~FLAG_HAS_WOL;
>  		break;
>  
