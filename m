From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for January 31 (ip_vs)
Date: Mon, 31 Jan 2011 10:18:29 -0800
Message-ID: <20110131101829.b842da44.randy.dunlap@oracle.com>
References: <20110131174113.8199f901.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:52033 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579Ab1AaSTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 13:19:07 -0500
In-Reply-To: <20110131174113.8199f901.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Jan 2011 17:41:13 +1100 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20110121:
> 
> The net tree lost its build failure.


When CONFIG_SYSCTL is not enabled:

net/netfilter/ipvs/ip_vs_core.c:1891: warning: format '%lu' expects type 'long unsigned int', but argument 2 has type 'unsigned int'
ERROR: "unregister_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko] undefined!
ERROR: "register_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko] undefined!


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
