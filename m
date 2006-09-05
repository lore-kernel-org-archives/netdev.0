From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.18-rc5-mm1: {dis,en}able_irq_lockdep_irqrestore compile error
Date: Tue, 5 Sep 2006 15:25:30 +0200
Message-ID: <20060905132530.GD9173@stusta.de>
References: <20060901015818.42767813.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:10757 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S964908AbWIENZi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 09:25:38 -0400
To: Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <20060901015818.42767813.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

lockdep-core-add-enable-disable_irq_irqsave-irqrestore-apis.patch causes 
the following compile error on frv:

<--  snip  -->

...
  LD      .tmp_vmlinux1
drivers/built-in.o: In function `ei_start_xmit':
8390.c:(.text+0x241c8): undefined reference to `disable_irq_nosync_lockdep_irqsave'
8390.c:(.text+0x242a0): undefined reference to `enable_irq_lockdep_irqrestore'
8390.c:(.text+0x2440c): undefined reference to `enable_irq_lockdep_irqrestore'
make: *** [.tmp_vmlinux1] Error 1

<--  snip  -->

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

