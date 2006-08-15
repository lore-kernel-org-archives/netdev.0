From: Bill Nottingham <notting@redhat.com>
Subject: bonding: cannot remove certain named devices
Date: Tue, 15 Aug 2006 15:48:57 -0400
Message-ID: <20060815194856.GA3869@nostromo.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46261 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932518AbWHOTs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 15:48:58 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2.6.17-rc4+.

Trivial example:

# modprobe bonding (creates bond0)
# ip link set bond0 name "a b"
# echo "-a b" > /sys/class/net/bonding_masters 
bonding: unable to delete non-existent bond a
bash: echo: write error: No such device

Bill
