From: Nico Schottelius <nico-linux-20111201@schottelius.org>
Subject: BCM43224: 00:00:00:00:00:00 address (3.2.0-rc3-00099-g883381d)
Date: Thu, 1 Dec 2011 23:48:51 +0100
Message-ID: <20111201224851.GB20536@ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: b43-dev@lists.infradead.org, nico-linux-20111201@schottelius.org
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

just received another version of the macbook air, which is
labeled MacBookAir4,2 again.

This time I'm on Linus' 3.2.0-rc3-00099-g883381d and cannot
use the integrated wifi:

[23:43] brief:drivers# ip l show wlan0 
2: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
[23:43] brief:drivers# ip l s wlan0 up
RTNETLINK answers: Cannot assign requested address

It seems this time b43 is responsible for the card, not brcmsmac
anymore (superseeded it seems).

Is there a working tree out there somewhere? :-)

Cheers,

Nico

-- 
PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0
