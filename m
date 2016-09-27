From: "Amir Vadai\"" <amir@vadai.me>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Use a proper mask value
 for enc key id parameter
Date: Tue, 27 Sep 2016 12:30:38 +0300
Message-ID: <20160927093038.GA24373@office.localdomain>
References: <1474964478-4483-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Amir Vadai <amirva@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36486 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753121AbcI0Jan (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 05:30:43 -0400
Received: by mail-wm0-f49.google.com with SMTP id w84so164750176wmg.1
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 02:30:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1474964478-4483-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2016 at 11:21:18AM +0300, Hadar Hen Zion wrote:
> The current code use the encapsulation key id value as the mask of that
> parameter which is wrong. Fix that by using a full mask.
> 
> Fixes: bc3103f1ed40 ('net/sched: cls_flower: Classify packet in ip tunnels')
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> ---

Acked-by: Amir Vadai <amir@vadai.me>
