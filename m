From: Christoph Lameter <cl@linux.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Tue, 22 Nov 2011 10:41:02 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1111221040300.28197@router.home>
References: <alpine.DEB.2.00.1111221033350.28197@router.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
  Christian Kujau <lists@nerdbynature.de>,
  Benjamin Herrenschmidt <benh@kernel.crashing.org>,
  "Alex,Shi" <alex.shi@intel.com>,
  "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
  "linux-mm@kvack.org" <linux-mm@kvack.org>,
  Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>,
  "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <alpine.DEB.2.00.1111221033350.28197@router.home>
Content-ID: <alpine.DEB.2.00.1111221040302.28197@router.home>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Nov 2011, Christoph Lameter wrote:

> It may be easier to simply disable interrupts early in __slab_free
> if debugging is on. Doesnt look nice right now. Draft patch (not tested
> yet):

Well thats not enough. We have to take the slab_lock to stop validate_slab
from checking up on things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
