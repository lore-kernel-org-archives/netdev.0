From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: tso: add support for IPv6
Date: Mon, 26 Oct 2015 07:56:46 -0700
Message-ID: <1445871406.7476.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445803107-18513-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1445848289-26106-1-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	egrumbach@gmail.com
To: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35653 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932203AbbJZO4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 10:56:49 -0400
In-Reply-To: <1445848289-26106-1-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-10-26 at 10:31 +0200, Emmanuel Grumbach wrote:
> Adding IPv6 for the TSO helper API is trivial:
> * Don't play with the id (which doesn't exist in IPv6)
> * Correctly update the payload_len (don't include the
>   length of the IP header itself)
> 
> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
> ---
> v3: use vlan_get_protocol and call it once in tso_start
>     store the result in tso_t

Acked-by: Eric Dumazet <edumazet@google.com>

Next step, adding encapsulation support ;)
