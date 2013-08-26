From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH RESEND V3 net-next 2/3] net: huawei_cdc_ncm: Introduce
 the huawei_cdc_ncm driver
Date: Mon, 26 Aug 2013 14:05:55 -0700
Message-ID: <1377551155.1877.18.camel@joe-AO722>
References: <1377244590-8558-3-git-send-email-mrkiko.rs@gmail.com>
	 <20130826.163125.1134768821551948034.davem@davemloft.net>
	 <1377549913.1877.12.camel@joe-AO722>
	 <20130826.165831.112649899191508957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mrkiko.rs@gmail.com, gregkh@linuxfoundation.org, oliver@neukum.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130826.165831.112649899191508957.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-08-26 at 16:58 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Mon, 26 Aug 2013 13:45:13 -0700
> 
> > I think the premise of local variable
> > declaration by line length is flawed.
> 
> I disagree.
> 
> > It can't work when local variables are
> > dependent on initialization order as
> > above.
> 
> Move the initialization below the declarations.

So all initializations should be on separate
lines from declarations?

ick.

It's possible, but it doubles the associated
line count and I still think it's a very
dubious premise/practice/style.

As a general rule, it's I suppose OK, but as
a hardened rule, it's like most all hard rules.
It's made to be broken.
