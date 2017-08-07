From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] IP: do not modify ingress packet IP option in
 ip_options_echo()
Date: Sun, 06 Aug 2017 20:49:49 -0700 (PDT)
Message-ID: <20170806.204949.1692038476128309810.davem@davemloft.net>
References: <f5758b6b7199d2d2a218b0ad36f1e5ef108eac43.1500642854.git.pabeni@redhat.com>
        <20170724.141253.769254590231937263.davem@davemloft.net>
        <87a83othjl.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
        kuznet@ms2.inr.ac.ru
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50020 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751516AbdHGDtv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 23:49:51 -0400
In-Reply-To: <87a83othjl.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 28 Jul 2017 16:47:42 -0400

> David Miller <davem@davemloft.net> writes:
> 
>> The red flag is that we are indexing 'start' with 'doffset' instead of
>> 'soffset'.
> 
> As Paolo pointed out, we should not put our own source address into the
> options array.
> 
> Do you have any idea why this code was added in the first place? I read
> through 2.0.33 code and even in context of this version, I couldn't
> figure that out.
> 
> Because it seems the code and update is dead anyways (besides
> incorrectly updating the ICMP reflected payload) I don't see any problem
> with removing this code. Do you?

Ok, now I'm convinced it's dead code.

Thanks for explaining.
