From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Tue, 04 Jan 2005 18:28:38 -0500
Message-ID: <41DB26A6.2070008@pobox.com>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com> <1104764710.1048.580.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>,
        Tommy Christensen <tommy.christensen@tpack.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1104764710.1048.580.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> The change is simple if theres consensus to go this path.

Can you resend your patch?

My main objection was that any change should be made in the core, not in 
individual net drivers.

Another objection was that it seemed that some of the proposed solutions 
for clearing the queue on link down were imposing app-specific policy on 
the overall kernel.

Aren't there cases where people would -not- want the queue to be cleared?

	Jeff
