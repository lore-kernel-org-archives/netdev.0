From: Harsh <hanemade@gmail.com>
Subject: help in using eth_change_mtu
Date: Mon, 24 Jan 2005 14:29:27 +0530
Message-ID: <cfc9593605012400595e529682@mail.gmail.com>
Reply-To: Harsh <hanemade@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
         If some extra information is required to be sent with each
packet then does that require to change Ethernet MTU 1500 to
1500-(Bytes in extra info) or its ok with 1500 value of MTU? While
checking source code of net_init.c in drivers/net dir i found one
function eth_change_mtu. I want to know does that helps? why its given
there in source code?
regards,
Harsh.

static int eth_change_mtu(struct net_device *dev, int new_mtu)
 {
        if ((new_mtu < 68) || (new_mtu > 1500))
                 return -EINVAL;
        dev->mtu = new_mtu;
        return 0;
 }
