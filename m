From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Date: Fri, 23 Oct 2009 09:31:21 +0200
Message-ID: <20091023073120.GA16987@geggus.net>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>,
	Karol Lewandowski <karol.k.lewandowski@gmail.com>,
	Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	David Miller <davem@davemloft.net>,
	Reinette Chatre <reinette.chatre@intel.com>,
	Kalle Valo <kalle.valo@iki.fi>,
	David Rientjes <rientjes@google.com>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	Mohamed Abbas <mohamed.abbas@intel.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Stephan von Krawczynski <skraw@ithnet.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Mel Gorman schrieb am Donnerstag, den 22. Oktober um 16:22 Uhr:

> [No BZ ID] Kernel crash on 2.6.31.x (kcryptd: page allocation failure..)
> 	This apparently is easily reproducible, particular in comparison to
> 	the other reports. The point of greatest interest is that this is
> 	order-0 GFP_ATOMIC failures. Sven, I'm hoping that you in particular
> 	will be able to follow the tests below as you are the most likely
> 	person to have an easily reproducible situation.

I will see what I can do on the weekend. Unfortunately the crash happens on
a somewhat important machine and afterwards the Software-RAID needs a resync
which takes a few hours.

Sven

-- 
"Those who do not understand Unix are condemned to reinvent it, poorly"
(Henry Spencer)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
