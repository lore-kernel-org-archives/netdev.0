From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] NET: Multiple queue network device support REPOST
Date: Thu, 08 Mar 2007 23:26:41 -0800 (PST)
Message-ID: <20070308.232641.74749402.davem@davemloft.net>
References: <20070308.231142.74749203.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC329026E982F@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	christopher.leech@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46268
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2993047AbXCIH0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 02:26:42 -0500
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329026E982F@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Thu, 8 Mar 2007 23:16:58 -0800

> It seems expensive to change all the skb's if this type of
> event occurs,

The reset functions have to walk all the SKBs anyways.
