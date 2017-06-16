From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/5] skb data accessors cleanup
Date: Fri, 16 Jun 2017 09:07:42 +0200
Message-ID: <20170616070747.3332-1-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57650 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751948AbdFPHHv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 03:07:51 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.89)
        (envelope-from <johannes@sipsolutions.net>)
        id 1dLlMD-00040J-Pc
        for netdev@vger.kernel.org; Fri, 16 Jun 2017 09:07:49 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Over night, Fengguang's bot told me that it compiled all of its many
various configurations successfully, and I had done allyesconfig on
x86_64 myself yesterday to iron out the things I missed.

So now I think I'm happy with it.

My tree was based on your

    commit 3715c47bcda8bb56f7e2be27276282a2d0d48c09
    Merge: 18b6e7955d8f d8fbd27469fc
    Author: David S. Miller <davem@davemloft.net>
    Date:   Thu Jun 15 14:31:56 2017 -0400

        Merge branch 'r8152-support-new-chips'

when the compilation tests happened, but I've reviewed the changes
coming into net-next in the meantime and didn't see any new usages
of skb data accessors having come in.

johannes
