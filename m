From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] sh_eth: E-MAC interrupt handler cleanups
Date: Wed, 04 Jan 2017 15:09:36 +0300
Message-ID: <64514012.uUvlhX0YRQ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's a set of 3 patches against DaveM's 'net-next.git' repo. I'm cleaning
up the E-MAC interrupt handling with the main goal of factoring out the E-MAC
interrupt handler into a separate function.

[1/3] sh_eth: handle only enabled E-MAC interrupts
[2/3] sh_eth: no need for *else* after *goto*
[3/3] sh_eth: factor out sh_eth_emac_interrupt()

MBR, Sergei
