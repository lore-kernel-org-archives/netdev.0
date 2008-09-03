From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] sky2: EEPROM read/write bug fixes
Date: Wed, 03 Sep 2008 10:25:04 -0400
Message-ID: <48BE9E40.4010502@pobox.com>
References: <20080827204626.4b65862f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32967 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754836AbYICOZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:25:07 -0400
In-Reply-To: <20080827204626.4b65862f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Cleanup and harden the routines accessing the EEPROM.
>   1. Prevent spin forever waiting for the TWSI bus
>   2. Fix write eeprom to write full words rather than only 16 bits 
>     Luckly the vendor doesn't provide EEPROM in Linux format so it must never
>     have been used.
>   3. Don't allow partial eeprom writes, not needed, not safe.
> 
> These are non-urgent bug fixes.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

applied 1-2


