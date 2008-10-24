From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] oops in net_rx_action on 64-bit powerpc
Date: Fri, 24 Oct 2008 16:41:28 -0700 (PDT)
Message-ID: <20081024.164128.113131091.davem@davemloft.net>
References: <F169D4F5E1F1974DBFAFABF47F60C10A069DFCEF@orsmsx507.amr.corp.intel.com>
	<20081023.171614.72881694.davem@davemloft.net>
	<49025C94.60406@nortel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, romieu@fr.zoreil.com
To: cfriesen@nortel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50836
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751321AbYJXXlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 19:41:51 -0400
In-Reply-To: <49025C94.60406@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chris Friesen" <cfriesen@nortel.com>
Date: Fri, 24 Oct 2008 17:39:00 -0600

> So...it would appear that the NAPI code is somehow buggy, and
> 6ba33ac should probably be reverted until the problem is found and
> fixed.

No I think the problem is simple enough that someone should study the
->poll() routine quickly and audit it's return values.
