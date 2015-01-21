From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] sh_eth: massage PM code
Date: Thu, 22 Jan 2015 01:16:54 +0300
Message-ID: <5608250.lrFkJTjgSf@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's a set of 2 patches against DaveM's 'net-next.git' repo. We're adding
the support for suspend/hibernation as well as somewhat changing the existing
code. There are still MDIO-related issue with suspend (kernel exception), we've
been working on it and shall address it with a separate patch...

[1/2] sh_eth: use SET_RUNTIME_PM_OPS()
[2/2] sh_eth: add more PM methods

WBR, Sergei

