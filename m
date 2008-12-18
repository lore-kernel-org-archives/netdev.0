From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host communication.
Date: Thu, 18 Dec 2008 15:30:02 +0300
Message-ID: <20081218123002.GA5087@ioremap.net>
References: <4946717F.2090809@codemonkey.ws> <20081215.114315.165733593.davem@davemloft.net> <4946C1AA.4080404@codemonkey.ws> <20081215.142918.190909950.davem@davemloft.net> <4946E1BA.80206@codemonkey.ws> <20081215234511.GA24579@ioremap.net> <20081216065727.GD13794@redhat.com> <20081216212532.GA15360@ioremap.net> <20081217143146.GA20505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org
To: Gleb Natapov <gleb@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081217143146.GA20505@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gleb.

On Wed, Dec 17, 2008 at 04:31:46PM +0200, Gleb Natapov (gleb@redhat.com) wrote:
> Here it is. Sorry it is not in a patch format yet, but it gives
> general idea how it looks. The problem with connector is that 
> we need different IDX for different channels and there is no way
> to dynamically allocate them.

Looks very good. Especially liked how you used idx.val pairs to register
multiple users. Please add some comment in connector header on how you
use it and feel free to add my ack if needed.

-- 
	Evgeniy Polyakov
