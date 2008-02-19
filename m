From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Mon, 18 Feb 2008 16:32:00 -0800
Message-ID: <1203381120.13495.78.camel@dell>
References: <47BA0984.2070306@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Greg Kroah-Hartman" <gregkh@suse.de>, linux-kernel@vger.kernel.org
To: "Tony Battersby" <tonyb@cybernetics.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4503 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbYBSA3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 19:29:43 -0500
In-Reply-To: <47BA0984.2070306@cybernetics.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-18 at 17:41 -0500, Tony Battersby wrote:
> I am experiencing network data corruption with a 3Com 3C996B-T NIC
> (Broadcom NetXtreme BCM5701; driver tg3.ko).  I have identified the
> following patch as the trigger:

Assuming this problem is unique to the 5701, I'm not sure how it is
exposed by Herbert's patch.  One thing unique on the 5701 is that it
double-copies all RX packets so that the data starts at offset 2, but
that's quite unrelated to the patch below.

> 
> commit fb93134dfc2a6e6fbedc7c270a31da03fce88db9
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Wed Nov 14 15:45:21 2007 -0800
> 
>     [TCP]: Fix size calculation in sk_stream_alloc_pskb
>    
> 

> I do not get data corruption when substituting a SysKonnect 9D21 NIC
> (which also uses the tg3.ko driver)

What Broadcom chip is on the Syskonnect card?



