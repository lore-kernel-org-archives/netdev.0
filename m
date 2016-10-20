From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Fri, 21 Oct 2016 09:27:10 +1100
Message-ID: <20161021092710.1b56a35b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:49507 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753127AbcJTW1N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 18:27:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

After merging the net tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

ERROR: "kexec_in_progress" [drivers/net/dsa/bcm_sf2.ko] undefined!

Caused by commit

  2399d6143f85 ("net: dsa: bcm_sf2: Prevent GPHY shutdown for kexec'd kernels")

I used the version of the net tree from next-20161020 for today.

-- 
Cheers,
Stephen Rothwell
