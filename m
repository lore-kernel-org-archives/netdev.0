From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 01/14] etherdevice: Add eth_<foo>_addr
 CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS code
Date: Tue, 03 Mar 2015 10:42:05 -0800
Message-ID: <1425408125.5130.191.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1425354527.git.joe@perches.com>
	 <cccde434d9a32d1b9fb3d7604083c05a2ef1fe0e.1425354528.git.joe@perches.com>
	 <1425388752.5130.164.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425407104.17273.27.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425407104.17273.27.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 10:25 -0800, Joe Perches wrote:

> At least for arm gcc 4.6.3, it emits different code
> for net/l2tp/l2tp_eth.o

Then it looks like arm gcc or arm linux memset() should be improved.

Tracking all memset(x, y, 6) and replace them by some custom version
seems not very generic to me, when something better can be done.
