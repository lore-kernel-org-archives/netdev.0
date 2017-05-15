From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mdio: mux: fix device_node_continue.cocci warnings
Date: Mon, 15 May 2017 14:29:24 -0400 (EDT)
Message-ID: <20170515.142924.50104848465845824.davem@davemloft.net>
References: <20170512.122223.341607427763777325.davem@davemloft.net>
        <872f3980-9faa-718f-3260-9e4b22946140@gmail.com>
        <CAC3K-4qtjNOfseuENeg2Q7-xKVCK-Ytz2wPQMcX_LiwPLuTAiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, julia.lawall@lip6.fr, netdev@vger.kernel.org,
        andrew@lunn.ch, kbuild-all@01.org, linux-kernel@vger.kernel.org
To: jon.mason@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38242 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933211AbdEOS30 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 14:29:26 -0400
In-Reply-To: <CAC3K-4qtjNOfseuENeg2Q7-xKVCK-Ytz2wPQMcX_LiwPLuTAiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@broadcom.com>
Date: Mon, 15 May 2017 13:37:09 -0400

> I would prefer #1, as I would not want to break something that was
> currently working.  However, I think we should add much error logging
> here to let people know their DT is hosed (instead of silently
> working).  So, this would mean applying Julia's patch, and I'll do a
> follow-on to change the breaks to continues and add the error logging
> (assuming others agree with me).

Ok, I've applied Julia's patch.

I agree that we shouldn't fail the whole list just because one does.
And yes, we should emit enough diagnostics so that people can figure
out what the problem is.
