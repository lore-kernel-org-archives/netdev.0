From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/5] page allocator: Do not allow interrupts to use
 ALLOC_HARDER
Date: Fri, 23 Oct 2009 22:03:05 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0910232201520.9557@V090114053VZO-1>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-3-git-send-email-mel@csn.ul.ie> <20091022183303.2448942d.skraw@ithnet.com> <20091022163752.GU11778@csn.ul.ie>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephan von Krawczynski <skraw@ithnet.com>, Frans Pop <elendil@planet.nl>,
    Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>,
    Karol Lewandowski <karol.k.lewandowski@gmail.com>,
    Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>,
    David Miller <davem@davemloft.net>,
    Reinette Chatre <reinette.chatre@intel.com>,
    Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>,
    KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
    Mohamed Abbas <mohamed.abbas@intel.com>,
    Jens Axboe <jens.axboe@oracle.com>,
    "John W. Linville" <linville@tuxdriver.com>,
    Pekka Enberg <penberg@cs.helsinki.fi>,
    Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
    Greg Kroah-Hartman <gregkh@suse.de>,
    Kernel Testers List <kernel-testers@vger.kernel.org>,
    netdev@vger.kernel.org, linux-kernel@vger.kernel.or
To: Mel Gorman <mel@csn.ul.ie>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20091022163752.GU11778@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

There are now rt dependencies in the page allocator that screw things up?

And an rt flag causes the page allocator to try harder meaning it adds
latency.

?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
