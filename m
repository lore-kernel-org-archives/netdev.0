From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Date: Wed, 7 Oct 2015 09:06:52 -0700
Message-ID: <20151007160652.GK26924@tassilo.jf.intel.com>
References: <560ABE86.9050508@gmail.com>
 <20150930114255.13505.2618.stgit@canyon>
 <20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
 <20151002114118.75aae2f9@redhat.com>
 <20151002154039.69f82bdc@redhat.com>
 <20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
 <20151005212639.35932b6c@redhat.com>
 <20151005212045.GG26924@tassilo.jf.intel.com>
 <20151006010703.09e2f0ff@redhat.com>
 <20151007143120.7068416d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20151007143120.7068416d@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

> My specific CPU (i7-4790K @ 4.00GHz) unfortunately seems to have
> limited "Frontend" support. E.g. 
> 
>  # perf record -g -a -e stalled-cycles-frontend
>  Error:
>  The stalled-cycles-frontend event is not supported.
> 
> And AFAIK icache misses are part of "frontend".

Ignore stalled-cycles-frontend. It is very unreliable and has never worked right.
toplev gives you much more reliable output.


-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
