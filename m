From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH] atl1: fix frame length bug
Date: Mon, 14 Jan 2008 20:04:28 -0600
Message-ID: <20080114200428.1c62e8fb@osprey.hogchain.net>
References: <1200362201-30987-1-git-send-email-jacliburn@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>, csnook@redhat.com,
	david.harris@cpni-inc.com, netdev@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost01.isp.att.net ([204.127.217.101]:43493 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbYAOCEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 21:04:31 -0500
In-Reply-To: <1200362201-30987-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jan 2008 19:56:41 -0600
Jay Cliburn <jacliburn@bellsouth.net> wrote:

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

Jeff, Dave,

This bugfix needs to go in for 2.6.24 if possible.

Thanks,
Jay
