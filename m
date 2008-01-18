From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] atl1: fix frame length bug
Date: Fri, 18 Jan 2008 14:42:06 -0500
Message-ID: <4791010E.7030000@garzik.org>
References: <1200362201-30987-1-git-send-email-jacliburn@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, csnook@redhat.com, david.harris@cpni-inc.com,
	netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52296 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757190AbYARTmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 14:42:10 -0500
In-Reply-To: <1200362201-30987-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> The driver sets up the hardware to accept a frame with max length
> equal to MTU + Ethernet header + FCS + VLAN tag, but we neglect to
> add the VLAN tag size to the ingress buffer.  When a VLAN-tagged
> frame arrives, the hardware passes it, but bad things happen
> because the buffer is too small.  This patch fixes that.
> 
> Thanks to David Harris for reporting the bug and testing the fix.
> 
> Tested-by: David Harris <david.harris@cpni-inc.com>
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>

applied


