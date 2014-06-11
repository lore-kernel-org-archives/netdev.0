From: David Miller <davem@davemloft.net>
Subject: Re: [patch] drivers: net: davinci_cpdma: double free on error
Date: Wed, 11 Jun 2014 15:40:54 -0700 (PDT)
Message-ID: <20140611.154054.1561256983795392462.davem@davemloft.net>
References: <20140611081651.GB29572@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, george.cherian@ti.com, christian.riesch@omicron.at,
	zonque@gmail.com, bigeasy@linutronix.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140611081651.GB29572@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 11 Jun 2014 11:16:51 +0300

> We recently change the kzalloc() to devm_kzalloc() so freeing "ctlr"
> here could lead to a double free.
> 
> Fixes: e194312854ed ('drivers: net: davinci_cpdma: Convert kzalloc() to devm_kzalloc().')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
