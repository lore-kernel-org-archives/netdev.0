From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH bridge 2/5] bridge: Add vlan to unicast fdb entries
Date: Thu, 23 Aug 2012 12:39:01 -0700
Message-ID: <20120823123901.08b7e13e@nehalam.linuxnetplumber.net>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
	<1345750195-31598-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40954 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754506Ab2HWTjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 15:39:19 -0400
In-Reply-To: <1345750195-31598-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Aug 2012 15:29:52 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
> index dd3f201..288ff10 100644
> --- a/include/linux/if_bridge.h
> +++ b/include/linux/if_bridge.h
> @@ -95,6 +95,7 @@ struct __fdb_entry {
>  	__u8 port_hi;
>  	__u8 pad0;
>  	__u16 unused;
> +#define fdb_vid unused

That is seriously ugly. Just change the structure definition
to use the value.
