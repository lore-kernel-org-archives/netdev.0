From: Andrew Lunn <andrew@lunn.ch>
Subject: mv643xx_eth.c merge gone bad...
Date: Mon, 31 Oct 2016 12:33:49 +0100
Message-ID: <20161031113349.GA8951@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        jgunthorpe@obsidianresearch.com, jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58588 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941086AbcJaLeD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 07:34:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave

The merge of commit 27058af401e49d88a905df000dd26f443fcfa8ce for
mv643xx_eth.c has gone bad:

@@@ -3203,12 -3204,6 +3220,15 @@@
        dev->priv_flags |= IFF_UNICAST_FLT;
        dev->gso_max_segs = MV643XX_MAX_TSO_SEGS;
  
++<<<<<<< HEAD
 +      /* MTU range: 64 - 9500 */
 +      dev->min_mtu = 64;
 +      dev->max_mtu = 9500;
 +
 +      SET_NETDEV_DEV(dev, &pdev->dev);
 +
++=======
++>>>>>>> 2a26d99b251b8625d27aed14e97fc10707a3a81f
        if (mp->shared->win_protect)
                wrl(mp, WINDOW_PROTECT(mp->port_num), mp->shared->win_protect);
  
  Andrew
