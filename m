From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] RxRPC: Declare the security index constants
 symbolically
Date: Tue, 15 Sep 2009 02:46:11 -0700 (PDT)
Message-ID: <20090915.024611.108935670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59083
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751261AbZIOJpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 05:45:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All 4 patches applied, but...

The rxrpc code seems to use a hodge-podge of uint32_t, uint16_t et
al. and the Linux kernel preferred "u8".

Please consolidate it all to use u32, u16, etc.

This looks especially weird since you use the endianness aware
fixed sized Linux types (be32, be16) as well.
