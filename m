From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Introduce sk_clone_lock() error path routine
Date: Thu, 02 Mar 2017 13:59:27 -0800 (PST)
Message-ID: <20170302.135927.5220767141128338.davem@davemloft.net>
References: <20170301193508.25760-1-acme@kernel.org>
        <20170301193508.25760-2-acme@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@redhat.com, xiyou.wangcong@gmail.com,
        dvyukov@google.com, edumazet@google.com, gerrit@erg.abdn.ac.uk,
        tglx@linutronix.de
To: acme@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39010 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751553AbdCBWJQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 17:09:16 -0500
In-Reply-To: <20170301193508.25760-2-acme@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@kernel.org>
Date: Wed,  1 Mar 2017 16:35:08 -0300

> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> When handling problems in cloning a socket with the sk_clone_locked()
> function we need to perform several steps that were open coded in it and
> its callers, so introduce a routine to avoid this duplication:
> sk_free_unlock_clone().
> 
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Link: http://lkml.kernel.org/n/net-ui6laqkotycunhtmqryl9bfx@git.kernel.org
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied.
