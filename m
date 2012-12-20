From: John Greene <jogreene@redhat.com>
Subject: Re: [PATCH] 8139cp: Prevent dev_close/cp_interrupt race on MTU change
Date: Thu, 20 Dec 2012 08:55:40 -0500
Message-ID: <50D318DC.1020609@redhat.com>
References: <1355946468-3290-1-git-send-email-jogreene@redhat.com>  <20121219.124014.891279563982531558.davem@davemloft.net> <1355950547.18919.93.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923Ab2LTNzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 08:55:47 -0500
In-Reply-To: <1355950547.18919.93.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2012 03:55 PM, David Woodhouse wrote:
> On Wed, 2012-12-19 at 12:40 -0800, David Miller wrote:
>> You sent this as a "request for testing" last week, but I saw
>> no testing on real hardware whatsoever.
>
> Thanks for the reminder :)
>
> Seems to work fine here. I haven't confirmed whether I actually see the
> race or not but changing MTU on a live device works fine, even when it's
> being ping-flooded.
>
> Tested-by: David Woodhouse <David.Woodhouse@intel.com>
>
Thanks all. Happy holidays!

-- 
John Greene
