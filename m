From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] openvswitch: Fix incorrect type use.
Date: Wed, 21 Oct 2015 10:21:33 +0200
Message-ID: <20151021082133.GA15539@pox.localdomain>
References: <1445399266-2034-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35897 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932115AbbJUIVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 04:21:36 -0400
Received: by wicfx6 with SMTP id fx6so79598973wic.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 01:21:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445399266-2034-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/15 at 08:47pm, Pravin B Shelar wrote:
> Patch fixes following sparse warning.
> net/openvswitch/flow_netlink.c:583:30: warning: incorrect type in assignment (different base types)
> net/openvswitch/flow_netlink.c:583:30:    expected restricted __be16 [usertype] ipv4
> net/openvswitch/flow_netlink.c:583:30:    got int
> 
> Fixes: 6b26ba3a7d ("openvswitch: netlink attributes for IPv6 tunneling")
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
