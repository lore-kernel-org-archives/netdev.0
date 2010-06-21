From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] bonding: remove unused macro "pr_fmt""
Date: Mon, 21 Jun 2010 22:44:11 +0200
Message-ID: <20100621204411.GL2656@psychotron.bos.redhat.com>
References: <20100621193405.GG2656@psychotron.bos.redhat.com>
 <20100621.133806.226761715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758396Ab0FUUoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 16:44:14 -0400
Content-Disposition: inline
In-Reply-To: <20100621.133806.226761715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 21, 2010 at 10:38:06PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Mon, 21 Jun 2010 21:34:06 +0200
>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>...
>> -#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>> -
>
>Jiri, it is used by every single pr_*() logging call made
>in this file.
>
>I was hoping that this facilty and the voluminous amounty of pervasive
>usage of this in the networking drivers nowadays would make it
>familiar to active hackers like you :-)

Ough, right, missed that. That's just strange. I don't like this.

>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
