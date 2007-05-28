From: David Miller <davem@davemloft.net>
Subject: Re: EIP is at netlink_insert+0x41/0x10c
Date: Mon, 28 May 2007 00:36:20 -0700 (PDT)
Message-ID: <20070528.003620.59469636.davem@davemloft.net>
References: <a44ae5cd0705272347x5e37d4aeg1f6ac8ece0e1542c@mail.gmail.com>
	<20070527235234.fe2d4dab.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miles.lane@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52658
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751866AbXE1HgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2007 03:36:09 -0400
In-Reply-To: <20070527235234.fe2d4dab.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Sun, 27 May 2007 23:52:34 -0700

> I wonder how /bin/init got to run netlink stuff.

glibc uses it, but I don't think init does anything which would make
use of those features.
