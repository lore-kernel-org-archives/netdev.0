From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v3 1/3] packet: make aligned size of struct tpacket{2,3}_hdr
 clear
Date: Mon, 16 Dec 2013 11:05:05 +0100
Message-ID: <52AED051.3040906@redhat.com>
References: <87ppox6wq4.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	David Laight <David.Laight@ACULAB.COM>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37588 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769Ab3LPKFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 05:05:17 -0500
In-Reply-To: <87ppox6wq4.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2013 09:12 AM, Atzm Watanabe wrote:
> struct tpacket{2,3}_hdr is aligned to a multiple of TPACKET_ALIGNMENT.
> We may add members to them until current aligned size without forcing
> userspace to call getsockopt(..., PACKET_HDRLEN, ...).
>
> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
