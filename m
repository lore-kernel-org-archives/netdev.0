From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv4: fix validate_source for VRF setup
Date: Wed, 01 Nov 2017 21:27:05 +0900 (KST)
Message-ID: <20171101.212705.2148507954583659808.davem@davemloft.net>
References: <94ec60b10f8cfea08ec197ef4611c5a6061b96f1.1509455741.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53120 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754599AbdKAM1L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 08:27:11 -0400
In-Reply-To: <94ec60b10f8cfea08ec197ef4611c5a6061b96f1.1509455741.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 31 Oct 2017 14:32:38 +0100

> David reported breakages of VRF scenarios due to the
> commit 6e617de84e87 ("net: avoid a full fib lookup when rp_filter is
> disabled."): the local addresses based test is too strict when VRFs
> are in place.
> 
> With this change we fall-back to a full lookup when custom fib rules
> are in place; so that we address the VRF use case and possibly other
> similar issues in non trivial setups.
> 
> v1 -> v2:
>  - fix build breakage when CONFIG_IP_MULTIPLE_TABLES is not defined,
>    reported by the kbuild test robot
> 
> Reported-by: David Ahern <dsahern@gmail.com>
> Fixes: 6e617de84e87 ("net: avoid a full fib lookup when rp_filter is disabled.")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied.
