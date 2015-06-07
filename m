From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] net/xen-netfront: Correct printf format in
 xennet_get_responses
Date: Sun, 07 Jun 2015 02:00:05 -0700 (PDT)
Message-ID: <20150607.020005.1921032930953172020.davem@davemloft.net>
References: <1433432114-22198-1-git-send-email-julien.grall@citrix.com>
	<1433432114-22198-2-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	david.vrabel@citrix.com, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, netdev@vger.kernel.org
To: julien.grall@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433432114-22198-2-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julien Grall <julien.grall@citrix.com>
Date: Thu, 4 Jun 2015 16:35:13 +0100

> rx->status is an int16_t, print it using %d rather than %u in order to
> have a meaningful value when the field is negative.
> 
> Also use %d rather than %x for rx->offset.
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>
> Reviewed-by: David Vrabel <david.vrabel@citrix.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: netdev@vger.kernel.org
> 
> ---
>     Changes in v3:
>         - Use %d for the rx-offset too.

This change in v3 is wrong, 'rx->offset' is unsigned therefore %u is
the correct format string to use.
