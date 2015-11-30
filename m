From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: user-controllable kmalloc size in sctp_getsockopt_local_addrs
Date: Mon, 30 Nov 2015 14:36:37 -0200
Message-ID: <20151130163637.GA6091@mrl.redhat.com>
References: <CACT4Y+a_V5WQZNEnYkuA3Xc5qCWmLV3oScNeNiATZm-wW5eg3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+a_V5WQZNEnYkuA3Xc5qCWmLV3oScNeNiATZm-wW5eg3Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 28, 2015 at 01:40:08PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> The following program triggers WARNING in kmalloc:
> 

I messed up with the in-reply-to, put an extra c on it, but I just
posted a patch for this, subject:
[PATCH] sctp: use GFP_USER for user-controlled kmalloc

Thanks,
Marcelo
