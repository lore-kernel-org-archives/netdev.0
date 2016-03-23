From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre: fix return value of gre_rcv
Date: Wed, 23 Mar 2016 14:25:14 -0400 (EDT)
Message-ID: <20160323.142514.2266464870508750029.davem@davemloft.net>
References: <1458696883-15796-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458696883-15796-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Wed, 23 Mar 2016 09:34:43 +0800

> Dropped skb's should be documented by an appropriate return value.
> Use the correct NET_RX_DROP and NET_RX_SUCCESS values for that reason.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

IP protocol handlers do not use NET_RX_* values like this.

They either return 0, to finish processing, or a negative value which
indicates the negated protocol number to use to demux in the protocol
switch again.

Many of your patches seem very straightforward, but usually upon
further inspection severe fundamental issues with your changes are
found because you don't know what the proper semantics are for the
pieces of infrastructure you are touching.

Therefore, reviewing your seemingly trivial changes is a large
inventment of time and energy.

Please put more care into your changes, or else people will simply
stop reviewing your work and instead put their effort into submissions
which are more properly researched and easier to verify.

Thanks.
