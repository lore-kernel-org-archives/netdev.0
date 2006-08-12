From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] cleanup of the NETIF_F_* flag definitions
Date: Sat, 12 Aug 2006 15:37:32 -0400
Message-ID: <44DE2DFC.5030902@garzik.org>
References: <1155410647.13508.119.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:26057 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932588AbWHLThh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 15:37:37 -0400
To: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"David S. Miller" <davem@redhat.com>
In-Reply-To: <1155410647.13508.119.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Zijlstra wrote:
> Cleanup the NETIF_F_ flag definitions
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

If you are going to do a cleanup here, you should use the form that 
makes it _immediately_ obvious which bit(s) are being used:

#define NETIF_F_SG	(1 << 0)
#define NETIF_F_IP_CSUM	(1 << 1)
#define NETIF_F_NO_CSUM	(1 << 2)
[...]

Maybe DaveM's brain automatically translates all hex numbers into bit 
numbers, but not everybody's brain works that way... :)  It is better to 
use a form that requires no human brain translation...

	Jeff


