From: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
  failures V2
Date: Sat, 24 Oct 2009 09:48:19 +0300
Message-ID: <4AE2A333.6060307@cs.helsinki.fi>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <84144f020910220747nba30d8bkc83c2569da79bd7c@mail.gmail.com> <alpine.DEB.1.10.0910232151380.2001@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>, Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Sven Geggus <lists-+AJD3D7QEjjt/htJsj1pd9AswbaBtrod@public.gmane.org>,
	Karol Lewandowski <karol.k.lewandowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
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
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	" \" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds@l
To: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.1.10.0910232151380.2001@V090114053VZO-1>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Oct 2009, Pekka Enberg wrote:
>> These are pretty obvious bug fixes and should go to linux-next ASAP IMHO.

Christoph Lameter wrote:
> Bug fixes go into main not linux-next. Lets make sure these fixes really
> work and then merge.

Regardless, patches 1-2 and should _really_ go to Linus' tree (and 
eventually -stable) while we figure out the rest of the problems. They 
fix obvious regressions in the code paths and we have reports from 
people that they help. Yes, they don't fix everything for everyone but 
we there's no upside in holding back fixes that are simple one line 
fixes to regressions.

		Pekka
