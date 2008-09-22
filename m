From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11620] New: tun device's speed is set to ony
 10mbps
Date: Mon, 22 Sep 2008 16:20:18 -0700 (PDT)
Message-ID: <20080922.162018.256683293.davem@davemloft.net>
References: <bug-11620-10286@http.bugzilla.kernel.org/>
	<20080922161712.f4deeda4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vtun@office.satix.net,
	bugme-daemon@bugzilla.kernel.org, maxk@qualcomm.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56225
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753291AbYIVXUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 19:20:30 -0400
In-Reply-To: <20080922161712.f4deeda4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


TUN is a virtual device, not a physical one, it is just reporting
arbitrary values for things like link speed so that other aspects can
be discovered by standard tools (such as link state and offloading
features).

Please close this bug.
