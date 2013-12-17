From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v4 2/3] packet: fill the gap of TPACKET_ALIGNMENT with
 zeros
Date: Tue, 17 Dec 2013 15:03:18 +0100
Message-ID: <52B059A6.3020505@redhat.com>
References: <87eh5b7fdr.wl%atzm@stratosphere.co.jp>
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
Received: from mx1.redhat.com ([209.132.183.28]:28196 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752958Ab3LQODe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 09:03:34 -0500
In-Reply-To: <87eh5b7fdr.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 02:53 PM, Atzm Watanabe wrote:
> struct tpacket{2,3}_hdr is aligned to a multiple of TPACKET_ALIGNMENT.
> Explicitly defining and zeroing the gap of this makes additional changes
> easier.
>
> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
