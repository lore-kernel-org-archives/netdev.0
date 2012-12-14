From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/12] bonding: do not cancel works in bond_uninit()
Date: Fri, 14 Dec 2012 13:16:20 -0500 (EST)
Message-ID: <20121214.131620.98357907245917943.davem@davemloft.net>
References: <20121214110229.11019.63713.stgit@zurg>
	<20121214110255.11019.14759.stgit@zurg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, nikolay@redhat.com,
	netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: khlebnikov@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121214110255.11019.14759.stgit@zurg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 14 Dec 2012 15:02:55 +0400

> Bonding initializes these works in bond_open() and cancels in bond_close(),
> thus in bond_uninit() they are already canceled but may be unitialized yet.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Applied.
