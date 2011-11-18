From: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Subject: Re: [PATCH] iwl-debug: Shrink object by using dev_err and
 deduplicating formats
Date: Thu, 17 Nov 2011 19:14:16 -0800
Message-ID: <1321586056.11647.10.camel@wwguy-huron>
References: <1321580775.22117.8.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31094 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756387Ab1KREJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 23:09:30 -0500
In-Reply-To: <1321580775.22117.8.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-17 at 17:46 -0800, Joe Perches wrote:
> Using dev_err instead of dev_printk(KERN_ERR uses fewer
> arguments and is a bit smaller.
> 
> Deduplicating formats used by IWL_DEBUG_QUIET_RFKILL also
> makes the object a bit smaller.
>  
> Neatened the macros, used ##__VA_ARGS__.
> 
> $ size drivers/net/wireless/iwlwifi/built-in.o*
>    text	   data	    bss	    dec	    hex	filename
>  462652	   8646	  92576	 563874	  89aa2	drivers/net/wireless/iwlwifi/built-in.o.new
>  467557	   8646	  92592	 568795	  8addb	drivers/net/wireless/iwlwifi/built-in.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>
> ---
> \

very interesting. Thanks

Wey
