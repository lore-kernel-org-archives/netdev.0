From: David Miller <davem@davemloft.net>
Subject: Re: Linux 2.6.34-rc3 + CAN build problem
Date: Sat, 10 Apr 2010 15:50:09 -0700 (PDT)
Message-ID: <20100410.155009.66184583.davem@davemloft.net>
References: <1270892851.2093.32.camel@edumazet-laptop>
	<4BC054AE.7040303@freemail.hu>
	<4BC070E0.6070601@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nm127@freemail.hu, eric.dumazet@gmail.com,
	oliver.hartkopp@volkswagen.de, urs.thuermann@volkswagen.de,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BC070E0.6070601@hartkopp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Sat, 10 Apr 2010 14:36:48 +0200

> So i wonder why Nemeth trapped into this problem ... probably an include file
> mix-up?

Do you have CONFIG_DEBUG_STRICT_USER_COPY_CHECKS enabled in your
kernel config?

That's the only way you get an actual failure of a build when
the user copy size can't be proven to be in range by the
compiler, otherwise it just warns.
