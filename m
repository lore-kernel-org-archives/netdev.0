From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH 00/10] l2tp: misc fixes and add L2TPv3 IP encap over IPv6
Date: Mon, 23 Apr 2012 09:06:35 -0400
Message-ID: <20120423130635.GE768@kvack.org>
References: <1334912573-28804-1-git-send-email-jchapman@katalix.com> <20120422.002933.177233922611577116.davem@davemloft.net> <4F951F13.9060301@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:47040 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454Ab2DWNGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2012 09:06:36 -0400
Content-Disposition: inline
In-Reply-To: <4F951F13.9060301@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 23, 2012 at 10:21:23AM +0100, James Chapman wrote:
> Ok.
> 
> Ben, if I can help with the loopback checksum issue, please let me know.

The fix is pretty simple; in l2tp_xmit_ipv6_csum, change CHECKSUM_COMPLETE 
to CHECKSUM_UNNECESSARY (or CHECKSUM_NONE), as that will prevent the 
incoming sk_buff's ->csum value from being used (it's not correct).  I'm 
travelling at the moment, so I may not have time to respin the patch until 
Wednesday, but if I can, I will try to find the time this evening. 

		-ben
-- 
"Thought is the essence of where you are now."
