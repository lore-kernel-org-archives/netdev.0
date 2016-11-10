From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: hide unused local variable
Date: Wed, 09 Nov 2016 19:00:11 -0500 (EST)
Message-ID: <20161109.190011.497365572468997601.davem@davemloft.net>
References: <20161107211017.857340-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, hannes@stressinduktion.org, aduyck@mirantis.com,
        pshelar@ovn.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161107211017.857340-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon,  7 Nov 2016 22:09:07 +0100

> A bugfix introduced a harmless warning in v4.9-rc4:
> 
> drivers/net/vxlan.c: In function 'vxlan_group_used':
> drivers/net/vxlan.c:947:21: error: unused variable 'sock6' [-Werror=unused-variable]
> 
> This hides the variable inside of the same #ifdef that is
> around its user. The extraneous initialization is removed
> at the same time, it was accidentally introduced in the
> same commit.
> 
> Fixes: c6fcc4fc5f8b ("vxlan: avoid using stale vxlan socket.")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
