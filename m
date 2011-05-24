From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: linux-next: build failure after merge of the final tree
Date: Tue, 24 May 2011 00:10:35 -0400
Message-ID: <BANLkTim-zRShhy49d7yn5WTJYzR6A2DtZQ@mail.gmail.com>
References: <20110520161816.dda6f1fd.sfr@canb.auug.org.au> <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
 <BANLkTine2kobQA8TkmtiuXdKL=07NCo2vA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org,
	Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <BANLkTine2kobQA8TkmtiuXdKL=07NCo2vA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2011 at 00:01, Linus Torvalds wrote:
> On Mon, May 23, 2011 at 7:06 PM, Mike Frysinger wrote:
>>
>> more failures:
>
> Is this blackfin or something?

let's go with "something" ...

> I did an allyesconfig with a special x86 patch that should have caught
> everything that didn't have the proper prefetch.h include, but non-x86
> drivers would have passed that.

the isp1362-hcd failure probably is before your
268bb0ce3e87872cb9290c322b0d35bce230d88f.  i think i was reading a log
that is a few days old (ive been traveling and am playing catch up
atm).  i'll refresh and see what's what still.

the common musb code only allows it to be built if the arch glue is
available, and there is no x86 glue.  so an allyesconfig on x86
wouldnt have picked up the failure.  it'll bomb though for any target
which does have the glue.
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
