From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 7/8] isdn: replace CONFIG_8xx by CONFIG_PPC_8xx
Date: Thu, 12 Mar 2015 15:27:20 -0400 (EDT)
Message-ID: <20150312.152720.2248943963968220981.davem@redhat.com>
References: <20150312152409.E7B5C1A2422@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	linux-fbdev@vger.kernel.org, netdev@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-mtd@lists.infradead.org
To: christophe.leroy@c-s.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150312152409.E7B5C1A2422@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Thu, 12 Mar 2015 16:24:09 +0100 (CET)

> Two config options exist to define powerpc MPC8xx:
> * CONFIG_PPC_8xx
> * CONFIG_8xx
> In addition, CONFIG_PPC_8xx also defines CONFIG_CPM1 as
> communication co-processor
> 
> arch/powerpc/platforms/Kconfig.cputype has contained the following
> comment about CONFIG_8xx item for some years:
> "# this is temp to handle compat with arch=ppc"
> 
> It looks like not many places still have that old CONFIG_8xx used,
> so it is likely to be a good time to get rid of it completely ?
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

Acked-by: David S. Miller <davem@davemloft.net>
