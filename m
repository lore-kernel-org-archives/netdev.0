From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net] macvlan: add NETIF_F_NETNS_LOCAL flag
Date: Tue, 11 Feb 2014 02:45:35 +0100
Message-ID: <20140211014535.GA11150@order.stressinduktion.org>
References: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44988 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbaBKBph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 20:45:37 -0500
Content-Disposition: inline
In-Reply-To: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 05:36:33PM -0800, Cong Wang wrote:
> From: Cong Wang <cwang@twopensource.com>
> 
> BZ: https://bugzilla.kernel.org/show_bug.cgi?id=66691
> 
> There is no point to allow moving a macvlan device to
> another namespace while the lower device is still in
> this namespace. tunnels already set this flag.

Can't we solve this somehow differently, like not showing anything at all
etc.? I guess this is a feature some people use and haven't noticed yet.

Greetings,

  Hannes
