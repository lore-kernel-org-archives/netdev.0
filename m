From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Tue, 15 Aug 2017 12:28:49 +1000
Message-ID: <20170815122849.7042e167@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        David Wu <david.wu@rock-chips.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

arch/arm/boot/dts/rk3228-evb.dtb: ERROR (phandle_references): Reference to non-existent node or label "phy0"

Caused by commit

  db40f15b53e4 ("ARM: dts: rk3228-evb: Enable the integrated PHY for gmac")

Its possible that the error is caused by an interaction with another
commit, but I could not find anything obvious.  I have reverted that
commit for today.

-- 
Cheers,
Stephen Rothwell
