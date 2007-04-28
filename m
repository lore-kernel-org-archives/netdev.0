From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] ne: Add platform_driver
Date: Sat, 28 Apr 2007 00:57:27 -0700
Message-ID: <20070428005727.6414a24e.akpm@linux-foundation.org>
References: <20070425.015450.25909765.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org, jeff@garzik.org,
	ralf@linux-mips.org, sshtylyov@ru.mvista.com
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:36239 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031118AbXD1H5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 03:57:50 -0400
In-Reply-To: <20070425.015450.25909765.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Apr 2007 01:54:50 +0900 (JST) Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:

> @@ -880,4 +964,7 @@ void __exit cleanup_module(void)
>  		}
>  	}
>  }
> +#else /* MODULE */
> +module_init(ne_init);
> +module_exit(ne_exit);
>  #endif /* MODULE */

Are we sure about this part?  It is unusual to have special treatment dependent
upon MODULE.
