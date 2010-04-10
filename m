From: David Miller <davem@davemloft.net>
Subject: Re: Linux 2.6.34-rc3 + CAN build problem
Date: Sat, 10 Apr 2010 15:48:56 -0700 (PDT)
Message-ID: <20100410.154856.54433341.davem@davemloft.net>
References: <4BC03340.5020500@freemail.hu>
	<1270892851.2093.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nm127@freemail.hu, socketcan@hartkopp.net,
	oliver.hartkopp@volkswagen.de, urs.thuermann@volkswagen.de,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1270892851.2093.32.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 10 Apr 2010 11:47:31 +0200

> Could you give us your compiler version ?
> 
> Code is fine, but compiler a bit dumb :(

Build failures happen all over the kernel with that
USER_COPY_CHECK config option enabled, it's not really
a bug report and I've even told people like Stephen
Rothwell to do their allmodconfig builds on platforms
like sparc64 with this option hard disabled.
