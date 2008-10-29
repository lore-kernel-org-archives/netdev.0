From: Paul Moore <paul.moore@hp.com>
Subject: Re: linux-next: arm allmodconfig
Date: Wed, 29 Oct 2008 09:53:02 -0400
Message-ID: <200810290953.03105.paul.moore@hp.com>
References: <20081028175604.81c31cea.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Takashi Iwai <tiwai@suse.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>, xfs-masters@oss.sgi.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:28828 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373AbYJ2NxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 09:53:10 -0400
In-Reply-To: <20081028175604.81c31cea.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 28 October 2008 8:56:04 pm Andrew Morton wrote:
> > net/netlabel/netlabel_mgmt.c: In function `netlbl_mgmt_listentry':
> > net/netlabel/netlabel_mgmt.c:268: warning: 'ret_val' might be used
> > uninitialized in this function
>
> Assumes that netlbl_af4list_foreach_rcu() will never iterate zero
> times.
>
> Assumes that entry->type can never have an unexpected value.
>
> gcc cannot get this right, and C-level changes will be needed to shut
> this up.

No idea why this didn't come up when I was compiling this ... oh well, 
good thing I'm not a proud guy :)  I'll get this fixed and post a patch 
later today.

Thanks.

-- 
paul moore
linux @ hp
