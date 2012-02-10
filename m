From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: [PATCH] net: Don't proxy arp respond if iif == rt->dst.dev if
 private VLAN is disabled
Date: Fri, 10 Feb 2012 15:54:36 +0100
Message-ID: <1328885676.13582.18.camel@probook>
References: <1328882831-15300-1-git-send-email-tgraf@suug.ch>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:40215 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759442Ab2BJOyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 09:54:39 -0500
In-Reply-To: <1328882831-15300-1-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-10 at 15:07 +0100, Thomas Graf wrote:
> Commit 653241 (net: RFC3069, private VLAN proxy arp support) changed
> the behavior of arp proxy to send arp replies back out on the interface
> the request came in even if the private VLAN feature is disabled.
> 
> Previously we checked rt->dst.dev != skb->dev for in scenarios, when
> proxy arp is enabled on for the netdevice and also when individual proxy
> neighbour entries have been added.
> 
> This patch adds the check back for the pneigh_lookup() scenario.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Jesper Dangaard Brouer <hawk@comx.dk>
