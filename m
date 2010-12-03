From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 07/17] sfc: Remove broken automatic
 fallback for invalid Falcon chip/board config
Date: Fri, 03 Dec 2010 09:09:10 -0800 (PST)
Message-ID: <20101203.090910.183050462.davem@davemloft.net>
References: <1291333490.3259.23.camel@bwh-desktop>
	<1291333621.3259.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42675
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752650Ab0LCRIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 12:08:44 -0500
In-Reply-To: <1291333621.3259.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 02 Dec 2010 23:47:01 +0000

> If the Falcon board config is invalid, we cannot proceed - we do not
> have a valid board type to pass to falcon_probe_board(), and if we
> kluge that to work with an unknown board then other initialisation
> code will crash.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
