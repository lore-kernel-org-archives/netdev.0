From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] do not give access to 1-1024 ports for autobinding
Date: Wed, 10 Oct 2007 15:55:47 -0700 (PDT)
Message-ID: <20071010.155547.43394152.davem@davemloft.net>
References: <20071010143449.GA10796@iris.sw.ru>
	<20071010084137.1963122e@freepuppy.rosehill>
	<470D04E1.9030505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, den@openvz.org,
	netdev@vger.kernel.org
To: dlunev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46129
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756573AbXJJWzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:55:45 -0400
In-Reply-To: <470D04E1.9030505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <dlunev@gmail.com>
Date: Wed, 10 Oct 2007 20:59:13 +0400

> They have sense for the case of multiple network namespaces, where root
> in the other namespace can be treated as a user to initial namespace.

This is a silly limitation to impose just for the sake of
namespaces, please don't add it.
