From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: swap only first 2 fields of mcc_wrb
Date: Sat, 23 Jan 2010 01:09:50 -0800 (PST)
Message-ID: <20100123.010950.263690634.davem@davemloft.net>
References: <20100122085136.GA19742@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51328
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752570Ab0AWJJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:09:38 -0500
In-Reply-To: <20100122085136.GA19742@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Fri, 22 Jan 2010 14:21:36 +0530

> Only the first two fields of mcc wrb - embedded, payload_len
> need to be cpu_to_le32() swapped while issuing a cmd to the hw.
> The fields tag0, tag1 are opaque and returned back to cpu as is...
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
