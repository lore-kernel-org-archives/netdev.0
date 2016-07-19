From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 1/6] libcxgb: add library module for Chelsio
 drivers
Date: Tue, 19 Jul 2016 10:43:11 -0700 (PDT)
Message-ID: <20160719.104311.2236254119909398910.davem@davemloft.net>
References: <cover.1468689125.git.varun@chelsio.com>
	<cover.1468689125.git.varun@chelsio.com>
	<c7109ba4c9c00f0580b8e603a3c9ac53e5750ad4.1468689125.git.varun@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	gerlitz.or@gmail.com, swise@opengridcomputing.com,
	james.bottomley@hansenpartnership.com, indranil@chelsio.com,
	hariprasad@chelsio.com
To: varun@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbcGSRnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 13:43:15 -0400
In-Reply-To: <c7109ba4c9c00f0580b8e603a3c9ac53e5750ad4.1468689125.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varun Prakash <varun@chelsio.com>
Date: Sat, 16 Jul 2016 22:49:15 +0530

>  }
> +
> +static int __init libcxgb_init(void)
> +{
> +	return 0;
> +}
> +
> +static void __exit libcxgb_exit(void)
> +{
> +}
> +
> +module_init(libcxgb_init);
> +module_exit(libcxgb_exit);

If these functions don't have to do anything, you can remove this
entire sequence entirely.
