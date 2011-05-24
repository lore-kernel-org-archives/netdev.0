From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: linux-next: build failure after merge of the final tree
Date: Tue, 24 May 2011 10:29:58 -0700
Message-ID: <BANLkTi=7wfhw-J09U7X-crKcDUPwpzbsNA@mail.gmail.com>
References: <20110520161816.dda6f1fd.sfr@canb.auug.org.au> <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
 <BANLkTine2kobQA8TkmtiuXdKL=07NCo2vA@mail.gmail.com> <BANLkTim-zRShhy49d7yn5WTJYzR6A2DtZQ@mail.gmail.com>
 <BANLkTi=U8ikZo65AoxGznCopGMTFOUXWhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Dipankar Sarma <dipankar@in.ibm.com>, "Balbi, Felipe" <balbi@ti.com>
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <BANLkTi=U8ikZo65AoxGznCopGMTFOUXWhQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2011 at 10:10 AM, Mike Frysinger <vapier.adi@gmail.com> wro=
te:
>
> latest tree seems to only fail for me now on the musb driver. =A0i can
> send out a patch later today if no one else has gotten to it yet.

Please do.

I did a

  grep -L linux/prefetch.h $(git grep -l '[^a-z_]prefetchw*(' -- '*.[ch]')

but there are drivers out there that have that "prefetch()" pattern
without being about actual CPU prefetching at all (see for example
drivers/ide/cmd640.c), so once I got allyesconfig with my x86
detection hack going, I didn't bother with the few odd men out.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
