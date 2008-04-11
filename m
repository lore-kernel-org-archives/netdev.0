From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] forcedeth: new backoff implementation
Date: Fri, 11 Apr 2008 18:52:38 +0200
Message-ID: <200804111852.39156.netdev@axxeo.de>
References: <47FE7066.5060703@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:43853 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760098AbYDKQxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 12:53:49 -0400
In-Reply-To: <47FE7066.5060703@nvidia.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ayaz,

Ayaz Abdulla schrieb:
> This patch adds support for a new backoff algorithm for half duplex 
> supported in newer hardware. The old method is will be designated as 
> legacy mode.
> 
> Re-seeding random values for the backoff algorithms are performed when a 
> transmit has failed due to a maximum retry count (1 to 15, where max is 
> considered the wraparound case of 0).
> 
> Resending based on feedback.

It still uses u32 for the tables, which wastes at least 580 bytes
of code. Please use u16 for that.


Best Regards

Ingo Oeser
