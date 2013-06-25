From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] ipv6: remove old token ipv6 address as soon
 as possible
Date: Tue, 25 Jun 2013 09:56:19 +0200
Message-ID: <51C94D23.6020006@redhat.com>
References: <20130624200328.GJ13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25942 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751092Ab3FYH4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 03:56:24 -0400
In-Reply-To: <20130624200328.GJ13836@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2013 10:03 PM, Hannes Frederic Sowa wrote:
> If the tokenized ip address is re-set on an interface we depend on the
> arrival of a new router advertisment to call addrconf_verify to clean
> up the old address (which valid_lft is now set to 0). Old addresses can
> linger around for a longer time if e.g. the source of router advertisments
> vanishes.
>
> So, call addrconf_verify immediately after setting the new tokenized
> address to get rid of the old tokenized addresses.
>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Agreed. This is also done when simply adding or modifying an address, so this
would be good for tokenized addresses, too. I've tested it also and it looks
good. Thanks Hannes !

Acked-by: Daniel Borkmann <dborkman@redhat.com>
