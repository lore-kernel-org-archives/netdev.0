From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ixgbe: v3 normalize frag_list usage
Date: Mon, 25 Oct 2010 12:47:52 -0700 (PDT)
Message-ID: <20101025.124752.246526233.davem@davemloft.net>
References: <80769D7B14936844A23C0C43D9FBCF0F25B97A24B5@orsmsx501.amr.corp.intel.com>
	<20101006.235837.241424681.davem@davemloft.net>
	<80769D7B14936844A23C0C43D9FBCF0F25BC8DEC85@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35680
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757502Ab0JYTra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 15:47:30 -0400
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F25BC8DEC85@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Fri, 8 Oct 2010 16:57:40 -0700

> Below is the new and improved version of the RSC chaining approach.  Basically
> I am holding off on merging the SKB into the frame until the SKB has data in
> order to make it take a more standard approach.
> 
> Let me know if this will work with the new pointer structure.

This variant looks great, thanks Alexander!
