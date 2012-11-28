From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] br2684: don't send frames on not-ready vcc
Date: Wed, 28 Nov 2012 11:41:53 -0500 (EST)
Message-ID: <20121128.114153.737074131307295783.davem@davemloft.net>
References: <20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
	<1354055783.2534.18.camel@shinybook.infradead.org>
	<1354058916.2534.25.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: dwmw2@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354058916.2534.25.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Tue, 27 Nov 2012 23:28:36 +0000

> +	if (test_bit(ATM_VF_RELEASED, &atmvcc->flags)
> +	    || test_bit(ATM_VF_CLOSE, &atmvcc->flags)
> +	    || !test_bit(ATM_VF_READY, &atmvcc->flags)) {

Please:

	if (X ||
	    Y ||
	    Z)

not:

	if (X
	    || Y
	    || Z)

Thanks.
