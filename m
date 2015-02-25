From: Chris Rorvick <chris@rorvick.com>
Subject: Re: [PATCH] fib_trie: Add proc entry for next-hop exceptions
Date: Wed, 25 Feb 2015 00:02:45 -0600
Message-ID: <CAEUsAPafiEMsvrL6y7RUNv-z=-HUJvdi0O2aQuHHDV4mkRkZjg@mail.gmail.com>
References: <1424842032-3151-1-git-send-email-chris@rorvick.com>
	<20150225.003305.1943185648487924578.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:43531 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbbBYGCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 01:02:46 -0500
In-Reply-To: <20150225.003305.1943185648487924578.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 11:33 PM, David Miller <davem@davemloft.net> wrote:
> From: Chris Rorvick <chris@rorvick.com>
> Date: Tue, 24 Feb 2015 23:27:12 -0600
>
>> Exceptions are added to the FIB in response to ICMP redirects and to
>> account for PMTU, but there is little visibility into what the current
>> exceptions are.  Add a proc entry for listing the current next-hop
>> exceptions
>>
>> Signed-off-by: Chris Rorvick <chris@rorvick.com>
>
> Procfs exportation of networking information is deprecated.
>
> New pieces of information should be provided via netlink.

Ah, OK.  So is the premise of this patch still interesting or am I
just ignorant?  It seems like knowing whether or not you're
accumulating a lot of exceptions is interesting and I could not figure
out how to do that.

Thanks for the feedback.

Regards,

Chris
