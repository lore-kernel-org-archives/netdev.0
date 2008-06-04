From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/12] BE NIC driver - Header files and initialization
 functions
Date: Wed, 4 Jun 2008 10:11:33 -0700
Message-ID: <20080604101133.2188c8f6@extreme>
References: <20080604082514.241e7aad@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Subbu Seetharaman" <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:40440 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755113AbYFDRLf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 13:11:35 -0400
In-Reply-To: <20080604082514.241e7aad@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 04 Jun 2008 01:25:14 -0700
"Subbu Seetharaman" <subbus@serverengines.com> wrote:

> Thanks for you comments Stephen.  
> 
> We did not make MSIx the default since most testing
> was done with INTx.  Since this version of the driver does not use multiple
> interrupt vectors, there is no performance advantage in using MSIx.
> If MSIx is still the preferred default, we can change it.

MSIx isn't shared but INTx is so there is at least some gain on big systems.

> 
> NAPI makes tasklet redundant in the RX completion processing; but
> we felt deffering TX completion processing to a tasklet is a better
> idea for 10Gb data rates than doing it in hard interrupt.

Okay, other drivers do TX completion processing  in NAPI handler.
It has the advantage of rate limiting the the TX completion in case
of really high transmit load.

> I will get back soon with other comments taken care of.
> 
> Subbu
>
