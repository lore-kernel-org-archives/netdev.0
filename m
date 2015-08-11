From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 Resend] net/fddi: remove HWM_REVERSE() macro
Date: Mon, 10 Aug 2015 22:37:50 -0700 (PDT)
Message-ID: <20150810.223750.1908561238664673104.davem@davemloft.net>
References: <1FEC219B-7AF2-47C9-8EBB-786EE6EADCE4@gmail.com>
	<39055924-5AA5-4DE0-8872-D2F107EA82F1@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: yalin.wang2010@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <39055924-5AA5-4DE0-8872-D2F107EA82F1@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: yalin wang <yalin.wang2010@gmail.com>
Date: Tue, 11 Aug 2015 13:11:22 +0800

> HWM_REVERSE() macro is unused, remove it.
> 
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>

You did not do as I asked you to, this patch is still corrupted
and there is no way you successfully applied what is in this patch.

> -#define        HWM_REVERSE(x)          ((((x)<<24L)&0xff000000L)       +       \
> -                                (((x)<< 8L)&0x00ff0000L)       +       \
> -                                (((x)>> 8L)&0x0000ff00L)       +       \
> -                                (((x)>>24L)&0x000000ffL))

This indentation here is spaces, whereas in the source files they
are TABS.

Your email client did this.

If you fail to properly verify that your outgoing patches are not
corrupted before submitting them here, I will stop reviewing and
considering your changes.

Thank you.
