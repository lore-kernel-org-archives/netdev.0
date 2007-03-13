From: David Miller <davem@davemloft.net>
Subject: Re: bridge: faster compare for link local addresses
Date: Mon, 12 Mar 2007 17:10:29 -0700 (PDT)
Message-ID: <20070312.171029.85409273.davem@davemloft.net>
References: <20070312162015.5d22cd68@dxpl.pdx.osdl.net>
	<45F5EAD3.8050501@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33844
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752965AbXCMAKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 20:10:30 -0400
In-Reply-To: <45F5EAD3.8050501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 12 Mar 2007 17:05:39 -0700

> Being paranoid - are there no worries about the alignment of dest?

If it's an issue, it's an issue elsewhere too, as the places
where Stephen took this idiomatic code from is the code
ethernet handling and that runs on every input packet via
eth_type_trans().
