From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: optimize Berkeley Packet Filter (BPF) processing
Date: Sun, 20 Jun 2010 15:09:28 -0700 (PDT)
Message-ID: <20100620.150928.245399526.davem@davemloft.net>
References: <1277003136-5522-1-git-send-email-hagen@jauu.net>
	<20100619221611.784f7dbc@nehalam>
	<20100620095019.GA32223@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34009
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753601Ab0FTWJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 18:09:16 -0400
In-Reply-To: <20100620095019.GA32223@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Sun, 20 Jun 2010 11:50:20 +0200

> * Stephen Hemminger | 2010-06-19 22:16:11 [-0700]:
> 
>>I don't think this works because it breaks ABI compatibility for applications tha
>>use older versions.
> 
> Are you sure Stephen? It is a one-to-one mapping of the ABI but maybe it was
> too late yesterday ... ;-)

I think from this perspective, the change is fine too, nothing visible
to the user is being changed here.
