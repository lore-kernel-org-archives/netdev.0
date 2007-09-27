From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rfkill: Move rfkill_switch_all out of global header
Date: Thu, 27 Sep 2007 14:57:25 -0700 (PDT)
Message-ID: <20070927.145725.25459181.davem@davemloft.net>
References: <200709280007.41676.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dtor@insightbb.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: ivdoorn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755540AbXI0V5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 17:57:25 -0400
In-Reply-To: <200709280007.41676.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivo van Doorn <ivdoorn@gmail.com>
Date: Fri, 28 Sep 2007 00:07:41 +0200

> rfkill_switch_all shouldn't be called by drivers directly,
> instead they should send a signal over the input device.
> 
> To prevent confusion for driver developers, move the
> function into a rfkill private header.
> 
> Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

Applied to net-2.6.24, thanks.
