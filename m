From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH v2] netconsole: enable netconsole can make net_device
 refcnt incorrent
Date: Wed, 12 Oct 2011 10:23:44 -0300
Message-ID: <20111012102344.0b718260@asterix.rh>
References: <1318385291-15483-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753032Ab1JLNXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Oct 2011 09:23:54 -0400
In-Reply-To: <1318385291-15483-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Oct 2011 10:08:11 +0800
Gao feng <gaofeng@cn.fujitsu.com> wrote:

> There is no check if netconsole is enabled current.
> so when exec echo 1 > enabled;
> the reference of net_device will increment always.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  drivers/net/netconsole.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)

Looks better, thanks!
Acked-by: Flavio Leitner <fbl@redhat.com>

fbl
