From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] lwtunnel: check return value of nla_nest_start
Date: Mon, 24 Apr 2017 15:51:40 -0400 (EDT)
Message-ID: <20170424.155140.436046246227486722.davem@davemloft.net>
References: <1492928917-25628-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, roopa@cumulusnetworks.com, ast@kernel.org,
        david.lebrun@uclouvain.be, tom@herbertland.com,
        rshearma@brocade.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: bianpan2016@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1492928917-25628-1-git-send-email-bianpan2016@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016@163.com>
Date: Sun, 23 Apr 2017 14:28:37 +0800

> Function nla_nest_start() may return a NULL pointer on error. However,
> in function lwtunnel_fill_encap(), the return value of nla_nest_start()
> is not validated before it is used. This patch checks the return value
> of nla_nest_start() against NULL.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.
