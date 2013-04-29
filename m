From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 0/3] Add support for velocity network driver on
 platform devices
Date: Mon, 29 Apr 2013 15:15:28 -0400 (EDT)
Message-ID: <20130429.151528.2251094691456287740.davem@davemloft.net>
References: <1367221841-14563-1-git-send-email-linux@prisktech.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	vt8500-wm8505-linux-kernel@googlegroups.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: linux@prisktech.co.nz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367221841-14563-1-git-send-email-linux@prisktech.co.nz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


You prepared these patches against a net-next tree which is at least
a week old, I know this because that's when the NETIF_F_* flags for
VLAN offloading changed their names which causes your third patch
to fail to apply.

Do not do this, net-next changes every day and rapidly, don't take
the chance that the driver you're touching is unpopular and thus
hasn't had changes to it recently.  Tree-wide interface changes
happen all the time.
