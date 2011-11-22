From: Christoph Lameter <cl@linux.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Tue, 22 Nov 2011 16:32:33 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1111221632230.30368@router.home>
References: <20111121131531.GA1679@x4.trippels.de>  <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121153621.GA1678@x4.trippels.de>  <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121161036.GA1679@x4.trippels.de>
  <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121173556.GA1673@x4.trippels.de>  <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121185215.GA1673@x4.trippels.de>
  <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop>  <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>  <alpine.DEB.2.00.1111212105330.19606@router.home>  <1321948113.27077.24.camel@edumazet-laptop>  <alpine.DEB.2.01.1111220038060.8000@trent.utfs.org>
 <1322000195.14573.13.camel@pasglop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christian Kujau <lists@nerdbynature.de>,
  Eric Dumazet <eric.dumazet@gmail.com>,
  Markus Trippelsdorf <markus@trippelsdorf.de>,
  "Alex,Shi" <alex.shi@intel.com>,
  "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
  "linux-mm@kvack.org" <linux-mm@kvack.org>,
  Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>,
  "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1322000195.14573.13.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Nov 2011, Benjamin Herrenschmidt wrote:

> Eric, Christoph, the generic version of this_cpu_cmpxchg() is not
> interrupt safe, so I suppose this patch should go in right ?

Correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
