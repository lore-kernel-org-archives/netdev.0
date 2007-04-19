From: David Miller <davem@davemloft.net>
Subject: Re: kernel BUG at net/core/skbuff.c in linux-2.6.21-rc6
Date: Thu, 19 Apr 2007 13:07:49 -0700 (PDT)
Message-ID: <20070419.130749.121296555.davem@davemloft.net>
References: <20070414.100441.15000708.davem@davemloft.net>
	<17953.30429.220756.818283@cargo.ozlabs.ibm.com>
	<17953.31345.138748.170210@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, poemann@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46161
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1766983AbXDSUHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 16:07:46 -0400
In-Reply-To: <17953.31345.138748.170210@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Mackerras <paulus@samba.org>
Date: Sun, 15 Apr 2007 11:05:53 +1000

> I wrote:
> 
> > So this doesn't change process_input_packet(), which treats the case
> > where the first byte is 0xff (PPP_ALLSTATIONS) but the second byte is
> > 0x03 (PPP_UI) as indicating a packet with a PPP protocol number of
> 
> I meant "the second byte is NOT 0x03", of course.

I've applied this patch, thanks Paul.
