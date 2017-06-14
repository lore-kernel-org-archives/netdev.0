From: Doug Ledford <dledford@redhat.com>
Subject: Re: [pull request][for-next 0/6] Mellanox mlx5 updates 2017-05-23
Date: Wed, 14 Jun 2017 15:30:13 -0400
Message-ID: <1497468613.7171.264.camel@redhat.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
         <20170525.120220.1812199263503283242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        ilant@mellanox.com
To: David Miller <davem@davemloft.net>, saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58414 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751735AbdFNTaP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 15:30:15 -0400
In-Reply-To: <20170525.120220.1812199263503283242.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-05-25 at 12:02 -0400, David Miller wrote:
> From: Saeed Mahameed <saeedm@mellanox.com>
> Date: Tue, 23 May 2017 14:43:58 +0300
> 
> > Hi Dave and Doug,
> > 
> > This series introduces some small updates and FPGA support to the
> mlx5
> > core/ethernet and IB drivers.
> > 
> > For more details please see below.
> > 
> > Please pull and let me know if there's any problem.
> 
> Ok, I've pulled this into net-next.
> 
> Doug let me know if there are any merge hassles we need to coordinate
> on.

Turns out that you had pulled this prior to your net-next tree making
it up to v4.12-rc3, while I had my -rc branch based on v4.12-rc3, so
when I pulled just up to your merge commit for this pull request, it
meant a later merge of my -rc branch would pull in a bunch of stuff
between here and -rc3.  So I ended up pulling your latest net-next as
of today as the easiest way to resolve that issue.  Now I can merge my
-rc branch in and it won't cause any extra noise in the merge.  It
seems to be a fairly regular pattern that I'm going to have to hold my
pull request to Linus until after your tree is pulled, so I might just
start planning on that from now on ;-)

-- 
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD
