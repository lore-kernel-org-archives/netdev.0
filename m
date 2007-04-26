From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 01/11] git-netdev-all: export ieee80211_debug_level
Date: Thu, 26 Apr 2007 08:35:52 -0400
Message-ID: <20070426123552.GA6992@tuxdriver.com>
References: <200704260723.l3Q7NE1I023820@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, dsd@gentoo.org,
	johannes@sipsolutions.net, josejx@gentoo.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3439 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754649AbXDZMwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 08:52:40 -0400
Content-Disposition: inline
In-Reply-To: <200704260723.l3Q7NE1I023820@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 12:23:14AM -0700, akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Someone has been forgetting their SubmitChecklist medicine.
> 
> ERROR: "ieee80211_debug_level" [net/ieee80211/ieee80211_crypt_ccmp.ko] undefined!

Sent a pull request to Jeff on Tuesday that should fix this.

> Fix some unneeded space-wasting initialisations, too.  How often must this be
> said?

> -static int debug = 0;
> -u32 ieee80211_debug_level = 0;
> -static struct proc_dir_entry *ieee80211_proc = NULL;
> +static int debug;
> +u32 ieee80211_debug_level;
> +static struct proc_dir_entry *ieee80211_proc;

ACK to these bits.

John

-- 
John W. Linville
linville@tuxdriver.com
