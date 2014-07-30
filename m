From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v3 0/3] pktgen: Upstreaming features useful for xen-netback/front testing
Date: Wed, 30 Jul 2014 17:20:08 +0100
Message-ID: <1406737212-23351-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Joe Perches <joe@perches.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Mathias Krause <minipli@googlemail.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is my work during stressing the xen network drivers, hopefully
others can benefit from it.
1/4: Filling payload with pattern, useful for checking data correctness when the
packets travelling without checksum (~ intrahost VM-to-VM). Already sent it
separately feq times, so its version number differs
2/4: fine-grained buffer geometrics
3/4: fix UDP checksuming
4/4: sending TCP GSO packets. This is an RFC yet, as I'm not certain about all
things changed here

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Joe Perches <joe@perches.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org

v2: respin for net-next changes

v3:
- code style changes and smaller bugfixes
- new patch to fix UDP checksuming
- rework TCP checksuming and GSO in the last patch
