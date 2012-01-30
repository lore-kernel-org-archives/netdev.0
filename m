From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Deinline __nlmsg_put and genlmsg_put. -7k code on
 i386 defconfig.
Date: Mon, 30 Jan 2012 15:22:27 -0500 (EST)
Message-ID: <20120130.152227.271855483278409371.davem@davemloft.net>
References: <1327952257-20623-1-git-send-email-vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vda.linux@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327952257-20623-1-git-send-email-vda.linux@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <vda.linux@googlemail.com>
Date: Mon, 30 Jan 2012 20:37:37 +0100

>    text	   data	    bss	    dec	    hex	filename
> 8455963	 532732	1810804	10799499 a4c98b	vmlinux.o.before
> 8448899	 532732	1810804	10792435 a4adf3	vmlinux.o
> 
> This change also removes commented-out copy of __nlmsg_put
> which was last touched in 2005 with "Enable once all users
> have been converted" comment on top.
> 
> Changes in v2: rediffed against net-next.
> 
> Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>

Applied, thanks.
