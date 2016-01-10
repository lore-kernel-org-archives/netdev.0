From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] Fix some dubious code in the Renesas Ethernet drivers
Date: Mon, 11 Jan 2016 00:26:07 +0300
Message-ID: <5859243.yu8qorLmay@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's a set of 2 patches against DaveM's 'net.git' repo. While initializing
EMAC the code tries to respect the duplex mode both programmed into ECMR and
stored in its own private data -- this just can't be right.

[1/2] ravb: stop reading ECMR in ravb_emac_init()
[2/2] sh_eth: stop reading ECMR in sh_eth_dev_init()

MBR, Sergei

