From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/9] Introduce support to lazy initialize
 mostly static keys
Date: Sat, 19 Oct 2013 19:46:35 -0400 (EDT)
Message-ID: <20131019.194635.2189923305870380269.davem@davemloft.net>
References: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 19 Oct 2013 21:48:50 +0200

> This series implements support for delaying the initialization of secret
> keys, e.g. used for hashing, for as long as possible. This functionality
> is implemented by a new macro, net_get_random_bytes.
> 
> I already used it to protect the socket hashes, the syncookie secret
> (most important) and the tcp_fastopen secrets.
> 
> Changelog:
> v2) Use static_keys in net_get_random_once to have as minimal impact to
>     the fast-path as possible.
> v3) added patch "static_key: WARN on usage before jump_label_init was called":
>     Patch "x86/jump_label: expect default_nop if static_key gets enabled
>     on boot-up" relaxes the checks for using static_key primitives before
>     jump_label_init. So tighten them first.
> v4) Update changelog on the patch "static_key: WARN on usage before
>     jump_label_init was called"

Although I was very skeptical about these changes when you first posted
them, I am quite happy with this series now.

Thanks for working on this and not giving up :-)

Series applied, thanks a lot!
