From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 00/19] mlxsw: Introduce TC Flower offload
 using TCAM
Date: Fri, 03 Feb 2017 16:56:56 -0500 (EST)
Message-ID: <20170203.165656.1477582799484401549.davem@davemloft.net>
References: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com, tom@herbertland.com,
        f.fainelli@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752441AbdBCV46 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:56:58 -0500
In-Reply-To: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  3 Feb 2017 10:28:50 +0100

> This patchset introduces support for offloading TC cls_flower and actions
> to Spectrum TCAM-base policy engine.
> 
> The patchset contains patches to allow work with flexible keys and actions
> which are used in Spectrum TCAM.
> 
> It also contains in-driver infrastructure for offloading TC rules to TCAM HW.
> The TCAM management code is simple and limited for now. It is going to be
> extended as a follow-up work.
> 
> The last patch uses the previously introduced infra to allow to implement
> cls_flower offloading. Initially, only limited set of match-keys and only
> a drop and forward actions are supported.
> 
> As a dependency, this patchset introduces parman - priority array
> area manager - as a library.
> 
> ---
> v1->v2:
> - patch11:
>   - use __set_bit and __test_and_clear_bit as suggested by DaveM
> - patch16:
>   - Added documentation to the API functions as suggested by Tom Herbert
> - patch17:
>   - use __set_bit and __clear_bit as suggested by DaveM

Series applied, thanks Jiri.
