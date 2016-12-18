From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qed: fix old-style function definition
Date: Sat, 17 Dec 2016 21:39:24 -0500 (EST)
Message-ID: <20161217.213924.1140198422054737923.davem@davemloft.net>
References: <20161216084808.1815139-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, arun.easi@cavium.com, hare@suse.de,
        jthumshirn@suse.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161216084808.1815139-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 16 Dec 2016 09:47:41 +0100

> The newly added file causes a harmless warning, with "make W=1":
> 
> drivers/net/ethernet/qlogic/qed/qed_iscsi.c: In function 'qed_get_iscsi_ops':
> drivers/net/ethernet/qlogic/qed/qed_iscsi.c:1268:29: warning: old-style function definition [-Wold-style-definition]
> 
> This makes it a proper prototype.
> 
> Fixes: fc831825f99e ("qed: Add support for hardware offloaded iSCSI.")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

APplied.
