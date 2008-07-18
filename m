From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 09:46:26 +0400
Message-ID: <20080718054626.GA3338@2ka.mipt.ru>
References: <20080717214222.GA29449@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:37322 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998AbYGRFqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 01:46:55 -0400
Content-Disposition: inline
In-Reply-To: <20080717214222.GA29449@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ingo.

On Thu, Jul 17, 2008 at 11:42:22PM +0200, Ingo Molnar (mingo@elte.hu) wrote:
> Pid: 5098, comm: gdm-binary Not tainted 2.6.26-tip #3094
>  [<c0186f99>] print_trailer+0xa9/0xf0
>  [<c018707b>] check_bytes_and_report+0x9b/0xc0
>  [<c01874ae>] check_object+0x19e/0x1e0
>  [<c0187ef1>] __slab_alloc+0x371/0x4e0
>  [<c0188552>] kmem_cache_alloc+0xb2/0xc0
>  [<c06732dc>] ? __alloc_skb+0x2c/0x110

Out of curiosity, why does it scream at allocation time?
Does SLUB have a debug check at freeing time? If so, how does it work
and why didn't it caught use after free there?

-- 
	Evgeniy Polyakov
