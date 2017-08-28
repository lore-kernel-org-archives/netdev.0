From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [ethtool] ethtool: Remove UDP Fragmentation Offload use from
 ethtool
Date: Mon, 28 Aug 2017 14:22:52 -0400
Message-ID: <20170828182251.GC3092@tuxdriver.com>
References: <1503923928-9419-1-git-send-email-tariqt@mellanox.com>
 <1503932411.11498.67.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Shaker Daibes <shakerd@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39153 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdH1SaM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 14:30:12 -0400
Content-Disposition: inline
In-Reply-To: <1503932411.11498.67.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 08:00:11AM -0700, Eric Dumazet wrote:
> On Mon, 2017-08-28 at 15:38 +0300, Tariq Toukan wrote:
> > From: Shaker Daibes <shakerd@mellanox.com>
> > 
> > UFO was removed in kernel, here we remove it in ethtool app.
> > 
> > Fixes the following issue:
> > Features for ens8:
> > Cannot get device udp-fragmentation-offload settings: Operation not supported
> > 
> > Tested with "make check"
> > 
> > Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
> > Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> > ---
> 
> 
> Hi guys
> 
> I would rather remove the warning, but leave the ability to switch UFO
> on machines running old kernel but a recent ethtool.
> 
> ethtool does not need to be downgraded every time we boot an old
> kernel ;)

No, definitely not.
 
> Thanks !

Tariq, will you be reworking this as Eric suggests?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
