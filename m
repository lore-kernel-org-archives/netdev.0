From: David Miller <davem@davemloft.net>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 26 Aug 2009 16:29:50 -0700 (PDT)
Message-ID: <20090826.162950.142223439.davem@davemloft.net>
References: <20090826.154410.95005620.davem@davemloft.net>
	<alpine.DEB.2.00.0908261901270.11291@gandalf.stny.rr.com>
	<20090826232304.GB25980@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, mingo@elte.hu, fweisbec@gmail.com,
	billfink@mindspring.com, netdev@vger.kernel.org, brice@myri.com,
	gallatin@myri.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35545
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750761AbZHZX3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 19:29:37 -0400
In-Reply-To: <20090826232304.GB25980@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 26 Aug 2009 19:23:04 -0400

> Dave, would you please revert commit 9ec04da7489d2c9ae01ea6e9b5fa313ccf3d35fb
> and 5a165657bef7c47e5ff4cd138f7758ef6278e87b?  That should remove the ftrace
> code, and leave the TRACE_EVENT tracepoint for skb_copy_datagram_to_iovec in
> place.  I'll submit a patch in the next few days to augment the TRACE_EVENT
> format to export all the data that I need.

Ok.
