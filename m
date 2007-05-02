From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/20][BNX2]: Bug fixes and more 5709 suppot.
Date: Wed, 02 May 2007 03:10:05 -0400
Message-ID: <4638394D.7020005@garzik.org>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56007 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992841AbXEBHKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 03:10:07 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> [PATCH 6/20][BNX2]: Update 5708 firmware.
> [PATCH 7/20][BNX2]: Update 5709 firmware part 1.
> [PATCH 8/20][BNX2]: Update 5709 firmware part 2.
> [PATCH 9/20][BNX2]: Update 5709 firmware part 3.
> [PATCH 10/20][BNX2]: Update 5709 firmware part 4.
> [PATCH 11/20][BNX2]: Update 5709 firmware part 5.


NAK.  Multiple patches for a single changes means you broke git bisect.

The 5709 firmware update should be in a single changeset (thus, single 
patch).

ACK, once patches 7-11 are combined into one.

	Jeff


