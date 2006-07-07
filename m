From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch 4/7] net_device list cleanup: drivers and non-IP
 protocols
Date: Fri, 7 Jul 2006 12:18:40 -0700
Message-ID: <20060707121840.2cbe1646@dxpl.pdx.osdl.net>
References: <20060630150823.A22285@castle.nmd.msu.ru>
	<20060630164715.F22285@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20683 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932244AbWGGTSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 15:18:42 -0400
To: Andrey Savochkin <saw@swsoft.com>
In-Reply-To: <20060630164715.F22285@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 3 Jul 2006 12:18:54 +0400
Andrey Savochkin <saw@swsoft.com> wrote:

> Cleanup of net_device list use in network device drivers and protocols
> other than IP.
> 
> The cleanup consists of
>  - converting the to list_head, to make the list double-linked (thus making
>    remove operation O(1)), and list walks more readable;

Maybe this should be RCU'd to get rid of the read_lock.

>  - introducing of for_each_netdev wrapper over list_for_each.
> 
> Signed-off-by: Andrey Savochkin <saw@swsoft.com>

Looks good thanks.
