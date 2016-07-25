From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net 0/3] macsec: fix configurable ICV length
Date: Mon, 25 Jul 2016 12:09:32 +0200
Message-ID: <20160725100932.GA4847@bistromath.localdomain>
References: <cover.1469191850.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145AbcGYKJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jul 2016 06:09:36 -0400
Content-Disposition: inline
In-Reply-To: <cover.1469191850.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-07-22, 15:07:55 +0200, Davide Caratti wrote:
> This series provides a fix for macsec configurable ICV length. The 
> maximum length of ICV element has been made compliant to IEEE 802.1AE,
> and error reporting in case of cipher suite configuration failure has been
> improved. Finally, a test has been added to netlink verify() callback in
> order to avoid creation of macsec interfaces having user-provided ICV length
> values that are not supported by the cipher suite.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
> 
> Davide Caratti (3):
>   macsec: limit ICV length to 16 octets
>   macsec: fix error codes when a SA is created
>   macsec: validate ICV length on link creation
> 
>  drivers/net/macsec.c           | 76 ++++++++++++++++++++++++++++--------------
>  include/uapi/linux/if_macsec.h |  2 ++
>  2 files changed, 53 insertions(+), 25 deletions(-)

Acked-by: Sabrina Dubroca <sd@queasysnail.net>

-- 
Sabrina
