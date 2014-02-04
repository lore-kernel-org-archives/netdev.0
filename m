From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fdtable: Avoid triggering OOMs from alloc_fdmem
Date: Tue, 04 Feb 2014 10:44:24 -0800
Message-ID: <1391539464.10160.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87r47jsb2p.fsf@xmission.com>
	 <1391530721.4301.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <871tzirdwf.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
  linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org,
  David Rientjes <rientjes@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <871tzirdwf.fsf@xmission.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-02-04 at 09:22 -0800, Eric W. Biederman wrote:

> The two code paths below certainly look good canidates for having
> __GFP_NORETRY added to them.  The same issues I ran into with
> alloc_fdmem are likely to show up there as well.

Yes, this is what I thought : a write into TCP socket should be more
frequent than the alloc_fdmem() case ;)

But then, maybe your workload was only using UDP ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
