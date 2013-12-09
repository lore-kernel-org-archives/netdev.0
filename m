From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sk == 0xffffffff fix - not for commit
Date: Mon, 09 Dec 2013 07:31:59 -0800
Message-ID: <1386603119.30495.331.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386589672-5830-1-git-send-email-andrzej.p@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Kyungmin Park <kyungmin.park@samsung.com>,
	Felipe Balbi <balbi@ti.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Michal Nazarewicz <mina86@mina86.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386589672-5830-1-git-send-email-andrzej.p@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-12-09 at 12:47 +0100, Andrzej Pietrasiewicz wrote:
> NOT FOR COMMITTING TO MAINLINE.
> 
> With g_ether loaded the sk occasionally becomes 0xffffffff.
> It happens usually after transferring few hundreds of kilobytes to few
> tens of megabytes. If sk is 0xffffffff then dereferencing it causes
> kernel panic.
> 
> This is a *workaround*. I don't know enough net code to understand the core
> of the problem. However, with this patch applied the problems are gone,
> or at least pushed farther away.

Is it happening on SMP or UP ?

Crash should happen earlier in __inet_lookup_established()
