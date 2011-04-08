From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Kernel panic when using bridge
Date: Fri, 8 Apr 2011 12:17:00 -0700
Message-ID: <20110408121700.0aad53fe@nehalam>
References: <4D9E62D9.5010400@scotdoyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Scot Doyle <lkml@scotdoyle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41548 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752612Ab1DHTRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 15:17:03 -0400
In-Reply-To: <4D9E62D9.5010400@scotdoyle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Apr 2011 20:20:25 -0500
Scot Doyle <lkml@scotdoyle.com> wrote:

> This kernel panic occurs when using a bridge. I would be grateful for 
> any ideas on how to correct it.
> 
> The panic was captured on two servers after three or four days of 
> minimal use, both configured as follows:
> - unpatched kernel 2.6.39-rc1 (commit 
> ecb78ab6f30106ab72a575a25b1cdfd1633b7ca2) with default .config options
> - br0 on single intel igb NIC (3 other NIC's unused)
> - br0 with ip address on distinct /27 subnet
> - br0:1 with ip address on distinct /24 subnet
> - br0:2 with ip address on distinct /24 subnet
> - no iptables rules
> - ebtables not installed
> 
> "net/bridge/br_netfilter.c" and "net/ipv4/ip_options.c" (in the current 
> 2.6.39-rc2 and in net-next-2.6) are identical to the versions used to 
> build this kernel.
> 

Please reproduce with exactly 2.6.39-rc2 there were some bug fixes
to make sure that header was initialized.


-- 
