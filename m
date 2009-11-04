From: Karol Lewandowski <karol.k.lewandowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Date: Wed, 4 Nov 2009 03:03:01 +0100
Message-ID: <20091104020301.GA7037@bizet.domek.prywatny>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <20091023165810.GA4588@bizet.domek.prywatny> <20091023211239.GA6185@bizet.domek.prywatny> <9ec2d7290910240646p75b93c68v6ea1648d628a9660@mail.gmail.com> <20091028114208.GA14476@bizet.domek.prywatny> <20091028115926.GW8900@csn.ul.ie> <20091030142350.GA9343@bizet.domek.prywatny> <20091102203034.GC22046@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karol Lewandowski <karol.k.lewandowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Sven Geggus <lists-+AJD3D7QEjjt/htJsj1pd9AswbaBtrod@public.gmane.org>,
	Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Mohamed Abbas <mohamed.abbas-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>
To: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091102203034.GC22046-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 02, 2009 at 08:30:34PM +0000, Mel Gorman wrote:
> Does applying the following on top make any difference?
> 
> ==== CUT HERE ====
> PM: Shrink memory before suspend

No, this patch didn't change anything either.

IIRC I get failures while free(1) shows as much as 20MB free RAM
(ie. without buffers/caches).  Additionaly nr_free_pages (from
/proc/vmstat) stays at about 800-1000 under heavy memory pressure
(gitk on full linux repository).


--- babbling follows ---

Hmm, I wonder if it's really timing issue then wouldn't be the case
that lowering swappiness sysctl would make problem more visible?
I've vm.swappiness=15, would testing with higher value make any sense?

Thanks.
