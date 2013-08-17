From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] sh_eth: don't get the register layout from platform data
Date: Sun, 18 Aug 2013 03:08:39 +0400
Message-ID: <201308180308.39941.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: lethal@linux-sh.org, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's a couple of patches making the 'sh_eth' driver get the register
layout from the internal data structures, not the platform data; this is
in preparation to adding device tree support to the driver. The patches are
against David Miller's 'net-next.git' repo and the couple of SH Ether fixes
I've just posted. David, if you decide to merge those SH patches into the
'net.git' repo, then a sync of it to 'net-next.git' would be required before
applying this series. 

[1/2] sh_eth: get register layout from 'struct sh_eth_cpu_data'
[2/2] sh_eth: remove 'register_type' field from 'struct sh_eth_plat_data'

WBR, Sergei
