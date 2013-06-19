From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] drivers/net: param for lapbether for specific
 ethernet device
Date: Wed, 19 Jun 2013 12:18:02 -0700 (PDT)
Message-ID: <20130619.121802.2112053686285060471.davem@davemloft.net>
References: <1371655613-31969-1-git-send-email-steve.moorby@ntlworld.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steve.moorby@ntlworld.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371655613-31969-1-git-send-email-steve.moorby@ntlworld.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Moorby <steve.moorby@ntlworld.com>
Date: Wed, 19 Jun 2013 16:26:53 +0100

> The lapbether driver binds to the first ethernet device that comes up.
> This causes problems in hardware with multiple ethernet interfaces,
> potentially resulting in the LAPB traffic on the wrong interface.
> Have added a module parameter 'eth_dev' to specify the ethernet
> interface over which lapbether should operate.  The module behaves
> as before if no device is specified.
> 
> Patch created on linux-next 18-Jun-2013.
> Tested on 2.6.32-45-generic.
> 
> Signed-off-by: Stephen Moorby <steve.moorby@ntlworld.com>

I rejected this patch last night, stating that module parameters are
deeply discouraged and therefore you need to create a runtime mechanism
to control this.
