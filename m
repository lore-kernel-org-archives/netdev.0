From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][CAN]: Fix copy_from_user() results interpretation.
Date: Fri, 25 Apr 2008 23:23:10 -0700 (PDT)
Message-ID: <20080425.232310.186704312.davem@davemloft.net>
References: <4811D1A6.909@openvz.org>
	<4811E915.80303@volkswagen.de>
	<4812C973.5000504@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver.hartkopp@volkswagen.de, xemul@openvz.org,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	urs.thuermann@volkswagen.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751497AbYDZGXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 02:23:11 -0400
In-Reply-To: <4812C973.5000504@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Sat, 26 Apr 2008 08:19:31 +0200

> What about removing the assignment "err =" in that case. It's confusing
> otherwise and maybe the variable err is even obsolete.

Sure, but when fixing a bug it's better to have a completely
localized change like this.

Not something which restructures the code unnecessarily at
the same time, that make it so much harder to review and
validate.
