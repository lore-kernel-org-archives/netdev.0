From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 0/2] Factor out register bit twiddling in the Renesas Ethernet drivers
Date: Wed, 10 Feb 2016 01:36:55 +0300
Message-ID: <2107757.v1oGBJ7aiG@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's a set of 2 patches against DaveM's 'net-next.git' repo. We factor out
the often repeated pattern of reading a register, AND'ing and/or OR'ing some
bits, and then writing the value back.

[1/2] ravb: factor out register bit twiddling code
[2/2] sh_eth: factor out register bit twiddling code

MBR, Sergei
