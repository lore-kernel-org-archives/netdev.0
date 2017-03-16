From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: hardware: mISDN: Remove reference to CONFIG_8xx
Date: Thu, 16 Mar 2017 11:15:34 -0700 (PDT)
Message-ID: <20170316.111534.1198546983950341144.davem@davemloft.net>
References: <20170316091802.E463D68481@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: christophe.leroy@c-s.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170316091802.E463D68481@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Thu, 16 Mar 2017 10:18:02 +0100 (CET)

> CONFIG_8xx is deprecated and should soon be removed in favor
> of CONFIG_PPC_8xx.
> Anyway, hfc_multi_8xx.h only uses 8xx I/O ports which are
> linked to the CPM1 communication processor included in the 8xx
> rather than the 8xx itself.
> 
> This patch therefore makes it dependent on CONFIG_CPM1 instead,
> like several other drivers.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

Applied.
