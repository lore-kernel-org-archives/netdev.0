From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fdtable: Avoid triggering OOMs from alloc_fdmem
Date: Tue, 04 Feb 2014 14:48:30 -0800
Message-ID: <1391554110.10160.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87r47jsb2p.fsf@xmission.com>
	 <1391530721.4301.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <871tzirdwf.fsf@xmission.com>
	 <1391539464.10160.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87r47ik8ou.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
  linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org,
  David Rientjes <rientjes@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <87r47ik8ou.fsf@xmission.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-02-04 at 10:57 -0800, Eric W. Biederman wrote:

> As I have heard it described one tcp connection per small requestion,
> and someone goofed and started creating new connections when the server
> was bogged down.  But since all of the requests and replies were small I
> don't expect even TCP would allocate more than a 4KiB page in that
> worload.

Right, small writes uses regular skb (no page fragments).

> 
> I had oodles of 4KiB and 8KiB pages.  What size of memory allocation did
> you see failing?  

We got some reports of order-3 allocations failing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
