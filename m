From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 4/5] bnx2x: improve memory handling, low memory
 recovery flows
Date: Tue, 03 May 2011 16:07:01 -0700 (PDT)
Message-ID: <20110503.160701.71113763.davem@davemloft.net>
References: <1304429337.19456.5.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32789
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753834Ab1ECXHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 19:07:34 -0400
In-Reply-To: <1304429337.19456.5.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Tue, 3 May 2011 16:28:57 +0300

>  
> +/**
> + * zeros the contents of the bp->fp[index].
> + * Makes sure the contents of the bp->fp[index]. napi is kept
> + * intact.
> + *
> + * @param bp
> + * @param index
> + */

I should have caught this in the past but I've only noticed it right
now.

Do not use your own, custom, format for documenting functions and
their arguments.

Use the standard DocBook comment format we use in the entire kernel.

The last thing we need is every single driver using their own custom
format.

Fix up the existing cases, or remove them completely.

Thanks.
