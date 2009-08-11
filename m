From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_PACKET: Fix PACKET_MMAP on 64-bit kernel/32-bit
 user systems
Date: Mon, 10 Aug 2009 18:06:03 -0700 (PDT)
Message-ID: <20090810.180603.36252332.davem@davemloft.net>
References: <20090810130359.p2hixk2eoow8kwg8@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cndougla@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39152
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752142AbZHKBFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 21:05:53 -0400
In-Reply-To: <20090810130359.p2hixk2eoow8kwg8@imap.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You can't make that change without breaking all existing
64-bit binaries running on 64-bit kernels.

Secondarily, we're already fully aware of this problem, that's why
there is a second version of the data structure named tpacket2_hdr
which was created in a way which fixes the problem without breaking
existing setups.
