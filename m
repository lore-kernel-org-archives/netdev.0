From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Socket filter access to hatype
Date: Wed, 21 Apr 2010 23:42:54 -0700 (PDT)
Message-ID: <20100421.234254.226227236.davem@davemloft.net>
References: <20100421172546.GO19334@cel.leo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leonerd@leonerd.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752222Ab0DVGmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 02:42:50 -0400
In-Reply-To: <20100421172546.GO19334@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Date: Wed, 21 Apr 2010 18:25:46 +0100

> When capturing packets on a PF_PACKET/SOCK_RAW socket bound to all
> interfaces, there doesn't appear to be a way for the filter program to
> actually find out the underlying hardware type the packet was captured
> on, such as is reported by the sll_hatype field of the struct sockaddr_ll
> when the packet is sent up to userland.
> 
> Unless I've managed to miss a trick somewhere, this would seem to put a
> fairly fundamental blocker on actually being able to filter in such
> packets. Granted there's the SKF_OFF_NET area to inspect at the e.g. IPv4
> level, but this makes it impossible to do anything on e.g. the Ethernet
> level.
> 
> See below for a patch to add an SKF_AD_HATYPE field, up among the other
> special access fields around SKF_AD_OFF.

This looks fine but you need to submit your patch properly,
including proper "Signed-off-by: " tags etc.  see
Documentation/SubmittingPatches for details.

Please make a complete fresh new submission, and don't try to shortcut
this by just replying and adding the Signed-off-by: or anything like
that.

Thanks.
