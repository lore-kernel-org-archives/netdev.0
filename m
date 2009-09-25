From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: Re: [PATCH] ax25: Fix ax25_cb refcounting in ax25_ctl_ioctl
Date: Fri, 25 Sep 2009 14:40:52 +0100
Message-ID: <20090925134052.GA1661@linux-mips.org>
References: <20090921201157.GA5460@del.dom.local> <4ABA9058.3010605@free.fr> <20090925131038.GA14778@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Bernard Pidoux <bernard.pidoux@upmc.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090925131038.GA14778@ff.dom.local>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 25, 2009 at 01:10:38PM +0000, Jarek Poplawski wrote:

> This bug isn't responsible for these oopses here, but looks quite
> obviously. (I'm not sure if it's easy to test/hit with the common
> tools.)

The issue your patch fixes is obvious enough.

> Jarek P.
> ------------>
> [PATCH] ax25: Fix ax25_cb refcounting in ax25_ctl_ioctl
> 
> Use ax25_cb_put after ax25_find_cb in ax25_ctl_ioctl.
> 
> Reported-by: Bernard Pidoux F6BVP <f6bvp@free.fr>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Reviewed-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
