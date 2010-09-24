From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next-2.6 1/2] net: Allow changing number of RX queues
 after device allocation
Date: Fri, 24 Sep 2010 08:34:30 -0700
Message-ID: <AANLkTik=pmH7nZc9uKPuX3DXcZ4nTiU=5x1CGBxyNhq7@mail.gmail.com>
References: <1285273118.7794.23.camel@achroite.uk.solarflarecom.com>
	<1285273194.7794.24.camel@achroite.uk.solarflarecom.com>
	<1285296505.2380.43.camel@edumazet-laptop>
	<1285331081.2257.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:63031 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab0IXPed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 11:34:33 -0400
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o8OFYWOm021223
	for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 08:34:32 -0700
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by wpaz13.hot.corp.google.com with ESMTP id o8OFYUAO001502
	for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 08:34:31 -0700
Received: by pxi12 with SMTP id 12so1119159pxi.18
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 08:34:30 -0700 (PDT)
In-Reply-To: <1285331081.2257.3.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks good to me.

>> All functions in this file use a single line.
>>
>> > -static int rx_queue_register_kobjects(struct net_device *net)
>> > +int
>> > +net_rx_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
>>
>> ->
>>
>> int net_rx_queue_update_kobjects(struct net_device *net, int old, int new)
>
> Why should I rename variables to fit a function signature on one line?
>
Maybe split the line within the parameter list, this would be more
consistent with other function declarations.
