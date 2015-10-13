From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] bridge: vlan: cleanups & fixes
	(part 3)
Date: Tue, 13 Oct 2015 04:58:28 -0700 (PDT)
Message-ID: <20151013.045828.226876535388974150.davem@davemloft.net>
References: <1444679225-7354-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: idosch@mellanox.com, bridge@lists.linux-foundation.org,
	nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, shm@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1444679225-7354-1-git-send-email-razor@blackwall.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Mon, 12 Oct 2015 21:47:01 +0200

> Patch 01 converts the vlgrp member to use rcu as it was already used in a
> similar way so better to make it official and use all the available RCU
> instrumentation. Patch 02 fixes a bug where the vlan_list can be traversed
> without rtnl or rcu held which could lead to using freed entries.
> Patch 03 removes some redundant code that isn't needed anymore.
> Patch 04 fixes a bug reported by Ido Schimmel about the vlan_flush order
> and switchdevs, it moves it back.
> 
> v2: patch 03 and 04 are new, couldn't escape the second synchronize_rcu()
> since the rhtable destruction can sleep

Series applied, thanks Nik.
