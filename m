From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] Renesas: propagate platform_get_irq() error upstream
Date: Fri, 28 Aug 2015 16:54:12 +0300
Message-ID: <9944836.IRPmWk4iN8@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org, horms@verge.net.au
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's 2 patches against DaveM's 'net.git' repo. We fix error handling for
platform_get_irq() that overrides the error code with -ENODEV which e.g.
prevents the deferred probing from working.

[1/2] ravb: propagate platform_get_irq() error upstream
[2/2] sh_eth: propagate platform_get_irq() error upstream

MBR, Sergei

