From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/8] flow_dissector: Protocol specific flow
 dissector offload
Date: Fri, 29 Sep 2017 18:42:45 +0100 (WEST)
Message-ID: <20170929.184245.412578447363431176.davem@davemloft.net>
References: <20170928235230.22158-1-tom@quantonium.net>
        <87y3oyylzv.fsf@stressinduktion.org>
        <CALx6S37J-Uv11TJuNFj4et==NFZj9W0v9s_c-Qowqcs--Kx_VQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, tom@quantonium.net,
        netdev@vger.kernel.org, rohit@quantonium.net
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752501AbdI2Rmv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 13:42:51 -0400
In-Reply-To: <CALx6S37J-Uv11TJuNFj4et==NFZj9W0v9s_c-Qowqcs--Kx_VQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Fri, 29 Sep 2017 08:48:55 -0700

> The flow_dissector interface is not a uAPI.

That's not true, insofar as cls_flower.c uses the flow_dissector
therefore if you change the flow_dissector in certain ways then
cls_flower.c might have it's behavior changed and that is in fact UAPI
facing.
