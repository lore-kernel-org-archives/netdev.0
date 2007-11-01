From: David Miller <davem@davemloft.net>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Thu, 01 Nov 2007 15:07:23 -0700 (PDT)
Message-ID: <20071101.150723.30590053.davem@davemloft.net>
References: <472A49BD.6000802@hp.com>
	<20071101.145956.63020380.davem@davemloft.net>
	<472A4D5C.2070301@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: djohnson+linux-kernel@sw.starentnetworks.com,
	greearb@candelatech.com, shemminger@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41545
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754215AbXKAWH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 18:07:29 -0400
In-Reply-To: <472A4D5C.2070301@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 01 Nov 2007 15:04:12 -0700

> David Miller wrote:
> > From: Rick Jones <rick.jones2@hp.com>
> > Date: Thu, 01 Nov 2007 14:48:45 -0700
> > 
> > 
> >>One could I suppose try to ammend the information passed to allow
> >>tcpdump to say "oh, this was a tx packet on the same machine on
> >>which I am tracing so don't worry about checksum mismatch"
> > 
> > 
> > We do this already!
> 
> I'll try to go pester folks in tcpdump-workers then.

The thing to check is "TP_STATUS_CSUMNOTREADY".

When using mmap(), it will be provided in the descriptor.  When using
recvmsg() it will be provided via a PACKET_AUXDATA control message
when enabled via the PACKET_AUXDATA socket option.


