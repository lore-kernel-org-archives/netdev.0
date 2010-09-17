From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers/net/usb/hso.c: prevent reading
 uninitialized memory
Date: Thu, 16 Sep 2010 21:55:35 -0700 (PDT)
Message-ID: <20100916.215535.128594045.davem@davemloft.net>
References: <1284587008.6275.95.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.dumon@option.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: drosenberg@vsecurity.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284587008.6275.95.camel@dan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Wed, 15 Sep 2010 17:43:28 -0400

> Fixed formatting (tabs and line breaks).
> 
> The TIOCGICOUNT device ioctl allows unprivileged users to read
> uninitialized stack memory, because the "reserved" member of the
> serial_icounter_struct struct declared on the stack in hso_get_count()
> is not altered or zeroed before being copied back to the user.  This
> patch takes care of it.
> 
> Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>

Applied.
