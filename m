From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH] atl1: fix frame length bug
Date: Fri, 18 Jan 2008 06:52:04 -0600
Message-ID: <20080118065204.1c999c08@osprey.hogchain.net>
References: <1200362201-30987-1-git-send-email-jacliburn@bellsouth.net>
	<20080114200428.1c62e8fb@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>, jeff@garzik.org,
	csnook@redhat.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([204.127.217.103]:49671 "EHLO
	fmailhost03.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758990AbYARMwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 07:52:06 -0500
In-Reply-To: <20080114200428.1c62e8fb@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jan 2008 20:04:28 -0600
Jay Cliburn <jacliburn@bellsouth.net> wrote:

> On Mon, 14 Jan 2008 19:56:41 -0600
> Jay Cliburn <jacliburn@bellsouth.net> wrote:
> 
> > The driver sets up the hardware to accept a frame with max length
> > equal to MTU + Ethernet header + FCS + VLAN tag, but we neglect to
> > add the VLAN tag size to the ingress buffer.  When a VLAN-tagged
> > frame arrives, the hardware passes it, but bad things happen
> > because the buffer is too small.  This patch fixes that.
> > 
> > Thanks to David Harris for reporting the bug and testing the fix.
> > 
> > Tested-by: David Harris <david.harris@cpni-inc.com>
> > Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> 
> Jeff, Dave,
> 
> This bugfix needs to go in for 2.6.24 if possible.

Dave,

I saw a message you sent awhile ago about Jeff handing off some netdev
stuff to you.  Since I haven't seen anything to rescind that notice,
I'll direct my request to you.

Could you please merge this patch for 2.6.24?
http://article.gmane.org/gmane.linux.network/83368

When the reporter hits the bug, the result is a locked up kernel.
Granted, it's triggered only in the presence of VLAN tagged frames, but
it's a serious bug and the fix is simple.

Jay
