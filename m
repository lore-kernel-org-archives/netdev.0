From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: linux-next: build failure after merge of the final tree
Date: Mon, 23 May 2011 21:01:39 -0700
Message-ID: <BANLkTine2kobQA8TkmtiuXdKL=07NCo2vA@mail.gmail.com>
References: <20110520161816.dda6f1fd.sfr@canb.auug.org.au> <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Dipankar Sarma <dipankar@in.ibm.com>
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2011 at 7:06 PM, Mike Frysinger <vapier.adi@gmail.com> wrote:
>
> more failures:

Is this blackfin or something?

I did an allyesconfig with a special x86 patch that should have caught
everything that didn't have the proper prefetch.h include, but non-x86
drivers would have passed that.

And I guess I didn't do my "force staging drivers on" hack for that test either.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
