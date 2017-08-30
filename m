From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] staging: irda: fix init level for irda core
Date: Wed, 30 Aug 2017 10:15:32 -0700 (PDT)
Message-ID: <20170830.101532.1535425571044102908.davem@davemloft.net>
References: <20170829173129.GA11029@kroah.com>
        <20170829174622.GA25926@kroah.com>
        <20170830111649.GA13000@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        samuel@sortiz.org, linux-kernel@vger.kernel.org,
        fengguang.wu@intel.com, geert@linux-m68k.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830111649.GA13000@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <gregkh@linuxfoundation.org>
Date: Wed, 30 Aug 2017 13:16:49 +0200

> When moving the IRDA code out of net/ into drivers/staging/irda/net, the
> link order changes when IRDA is built into the kernel.  That causes a
> kernel crash at boot time as netfilter isn't initialized yet.
> 
> To fix this, move the init call level of the irda core to be
> device_initcall() as the link order keeps this being initialized at the
> correct time.
> 
> Reported-by: kernel test robot <fengguang.wu@intel.com>
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
> 
> v3 - just change the initcall level, works so much simpler, thanks to
>      DaveM for the idea.
> v2 - don't force irda to be a module, make the Makefiles put irda back
>      where it was before in the link order.

Applied, thanks for following up on this Greg.
