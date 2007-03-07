From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] NET: Multiple queue network device support
Date: Wed, 07 Mar 2007 14:42:48 -0800 (PST)
Message-ID: <20070307.144248.48528321.davem@davemloft.net>
References: <20070226.170317.41636240.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC329026B6719@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	auke@foo-projects.org, john.ronciak@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48635
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992717AbXCGWmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 17:42:49 -0500
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329026B6719@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I didn't say to use skb->priority, I said to shrink skb->priority down
to a u16 and then make another u16 which will store your queue mapping
value.

