From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for August 15 (bnx2) [resend/lost]
Date: Fri, 15 Aug 2008 08:41:16 -0700
Message-ID: <20080815084116.340ac526.randy.dunlap@oracle.com>
References: <20080815184032.3acd8032.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, mchan@broadcom.com,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080815184032.3acd8032.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When VLAN is not enabled, bnx2 build fails with:

drivers/net/bnx2.c: In function 'bnx2_rx_int':
drivers/net/bnx2.c:2959: error: dereferencing pointer to incomplete type
drivers/net/bnx2.c:2960: error: dereferencing pointer to incomplete type
make[2]: *** [drivers/net/bnx2.o] Error 1


on these lines:

				ve->h_vlan_proto = htons(ETH_P_8021Q);
				ve->h_vlan_TCI = htons(vtag);


---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
