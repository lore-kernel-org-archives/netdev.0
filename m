From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND V3 net-next 2/3] net: huawei_cdc_ncm: Introduce
 the huawei_cdc_ncm driver
Date: Mon, 26 Aug 2013 16:58:31 -0400 (EDT)
Message-ID: <20130826.165831.112649899191508957.davem@davemloft.net>
References: <1377244590-8558-3-git-send-email-mrkiko.rs@gmail.com>
	<20130826.163125.1134768821551948034.davem@davemloft.net>
	<1377549913.1877.12.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mrkiko.rs@gmail.com, gregkh@linuxfoundation.org, oliver@neukum.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377549913.1877.12.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 26 Aug 2013 13:45:13 -0700

> I think the premise of local variable
> declaration by line length is flawed.

I disagree.

> It can't work when local variables are
> dependent on initialization order as
> above.

Move the initialization below the declarations.
