From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 7/7] netlink: allow to listen "all" netns
Date: Thu, 7 May 2015 13:55:59 +0200
Message-ID: <20150507115559.GC16619@pox.localdomain>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430989373-4515-8-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:34902 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbbEGL4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 07:56:02 -0400
Received: by wgyo15 with SMTP id o15so40994230wgy.2
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 04:56:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430989373-4515-8-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/15 at 11:02am, Nicolas Dichtel wrote:
> More accurately, listen all netns that have a nsid assigned into the netns
> where the netlink socket is opened.
> For this purpose, a netlink socket option is added:
> NETLINK_LISTEN_ALL_NSID. When this option is set on a netlink socket, this
> socket will receive netlink notifications from all netns that have a nsid
> assigned into the netns where the socket has been opened. The nsid is sent
> to userland via an anscillary data.
> 
> With this patch, a daemon needs only one socket to listen many netns. This
> is useful when the number of netns is high.
> 
> Because 0 is a valid value for a nsid, the field nsid_is_set indicates if
> the field nsid is valid or not. skb->cb is initialized to 0 on skb
> allocation, thus we are sure that we will never send a nsid 0 by error to
> the userland.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

LGTM, nice work

Acked-by: Thomas Graf <tgraf@suug.ch>
