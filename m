From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: xfrm hash to use Jenkins' hash
Date: Thu, 06 Aug 2009 10:40:20 -0700 (PDT)
Message-ID: <20090806.104020.231624975.davem@davemloft.net>
References: <ce10d01f0908050041p43c308fav72ac640f665e161f@mail.gmail.com>
	<20090805.120831.66033097.davem@davemloft.net>
	<ce10d01f0908052332o1db16460k58ed47849670c6de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joamaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59566
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756412AbZHFRkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 13:40:10 -0400
In-Reply-To: <ce10d01f0908052332o1db16460k58ed47849670c6de@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Maki <joamaki@gmail.com>
Date: Thu, 6 Aug 2009 09:32:37 +0300

> Should I pursue with fixing the inlining issue in my patch or would
> you have any suggestions how I could
> fix this by perhaps modifying __xfrm4_daddr_saddr_hash?

Do some different mixing in __xfrm4_daddr_saddr_hash(), it's still
going to be cheaper than jhash.
