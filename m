From: David Miller <davem@davemloft.net>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Thu, 04 Jun 2009 15:30:57 -0700 (PDT)
Message-ID: <20090604.153057.178458221.davem@davemloft.net>
References: <alpine.DEB.1.10.0906021044430.15692@gentwo.org>
	<20090603.224104.222901210.davem@davemloft.net>
	<alpine.DEB.1.10.0906041150590.3204@gentwo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org, yosefe@Voltaire.COM
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54026
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751308AbZFDWa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 18:30:56 -0400
In-Reply-To: <alpine.DEB.1.10.0906041150590.3204@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Thu, 4 Jun 2009 11:52:48 -0400 (EDT)

> On Wed, 3 Jun 2009, David Miller wrote:
> 
>> We don't do this for ARP, for example.  We have a 3 packet limit just
>> like IPoIB implements for multicast here.
> 
> ARP is a management protocol with specific semantics. Socket protocols are
> dealing with streams of datagrams.

Go look at what the ARP backlog queue actually does, then come back to
this conversation (hint: it's not a backlog for ARP packets, it's
a backlog for packets waiting for ARP to resolve).

Thank you.
