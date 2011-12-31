From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] 8139cp/8139too: do not read into reserved registers
Date: Sat, 31 Dec 2011 23:20:28 +0100
Message-ID: <1325370028.13595.143.camel@deadeye>
References: <20111231094433.5433.67602.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <akong@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:39337 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753251Ab1LaWUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Dec 2011 17:20:36 -0500
In-Reply-To: <20111231094433.5433.67602.stgit@dhcp-8-146.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-12-31 at 17:44 +0800, Jason Wang wrote:
> delay_eeprom() use long read for Cfg9346 register(offset 0x50) which may read
> into the area of reserved register(offset 0x53). Use byte read instead.
[...]

If they've been working like this for so long (from the start of git
history), maybe they're best left alone.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
