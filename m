From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] nfp: optimize XDP TX and small fixes
Date: Sun, 30 Apr 2017 22:37:44 -0400 (EDT)
Message-ID: <20170430.223744.1021414586941800017.davem@davemloft.net>
References: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com, kubakici@wp.pl
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54318 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425169AbdEAChq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:37:46 -0400
In-Reply-To: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu, 27 Apr 2017 21:06:14 -0700

> This series optimizes the nfp XDP TX performance a little bit.  
> I run quick tests on an Intel(R) Xeon(R) CPU E5-2630 v4 @ 2.20GHz.  
> Single core/queue performance for both touch and drop and touch and
> forward is above 20Mpps @64B packets, drop being 2Mpps faster.  
> I think this is max for a single queue on the low power NFPs.
> 
> There are also a few minor fixes included for code in net-next.

Series applied, thanks.
