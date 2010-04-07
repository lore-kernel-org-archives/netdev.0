From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 1/4] gianfar: Added stub support for
 SIOCSHWTSTAMP
Date: Wed, 07 Apr 2010 03:26:40 -0700 (PDT)
Message-ID: <20100407.032640.172296134.davem@davemloft.net>
References: <95DC1AA8EC908B48939B72CF375AA5E311A9F4DF@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sandeep.kumar@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Manfred.Rudigier@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51245
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757742Ab0DGK0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 06:26:38 -0400
In-Reply-To: <95DC1AA8EC908B48939B72CF375AA5E311A9F4DF@alice.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manfred Rudigier <Manfred.Rudigier@omicron.at>
Date: Wed, 7 Apr 2010 11:46:08 +0200

> This ioctl command is required for enabling hardware time stamping support
> for network packets, see Documentation/networking/timestamping.txt. At the
> moment nothing will be done for all requests that enable time stamping and
> thus ERANGE will be returned.
> 
> Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>

This is completely pointless.

Something sane should happen so that every driver doesn't
need to add this stub code just to return -ERANGE.
