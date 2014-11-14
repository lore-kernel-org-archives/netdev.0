From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH net-next] net: introduce SO_INCOMING_CPU
Date: Fri, 14 Nov 2014 15:40:20 -0800
Message-ID: <CALCETrVY3CPE=aCqqe5TPxw=f0Za0EMsKPcGn5ecwbtBKSBxHg@mail.gmail.com>
References: <1415393472.13896.119.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAHO5Pa0OGtgbUp4R287jbK2SFSpVUoXWCJybvHTFsGyCLynqLg@mail.gmail.com>
 <CALCETrXmCWSoeQLC3WCqMf_sehGVE9KTbTGmsA77ZN84B-V24Q@mail.gmail.com>
 <1415993614.17262.55.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+mtBx_DyUCxE6BqL_xXcqKPUDu7b3jLShV+AL6L+gCzJLriPg@mail.gmail.com>
 <CALCETrUuChgxXcNrKjYzpe1ry0hx3kf19EfAbY1N1YnG7NFZUw@mail.gmail.com>
 <CA+mtBx_tNW_Bz0hovZ90XxcLK6pL8d6RX=v5Rg8utfKkaFoJ+Q@mail.gmail.com>
 <CALCETrWYrR2X9u7CAr5xkSg8kLH_O=sdk=JF+ZW+FxCTNTFBZg@mail.gmail.com>
 <CA+mtBx9dSNOD5Z8GinU8F1mj_PgU0sTC5g8S9vRuSnSUzAoD=g@mail.gmail.com>
 <CALCETrXf8j52nmpw-A2+bQt0yoz-fiD-4GP4Qf-afwH6UjCVnw@mail.gmail.com>
 <1416003883.17262.72.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALCETrWhsj+byMeT=WHb9eLR_vgsUe58Li8JDLaTvsSPWp1DKQ@mail.gmail.com>
 <1416005912.17262.76.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALCETrUAd50g2mYEOKT-5pEqMvwSstfQcgU8=7GRsO1XcKBSFA@mail.gmail.com> <1416007946.17262.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ying Cai <ycai-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1416007946.17262.84.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 14, 2014 at 3:32 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Fri, 2014-11-14 at 15:03 -0800, Andy Lutomirski wrote:
>
>> If the kernel had an API for this, I'd be all for using it.
>
> It would be user land code, not kernel.
>
> Why doing a system call when you can avoid it ? ;)
>
> Doing it in the kernel would be quite complex actually.

A semi-official library would work, too.  As long as it kept working.

>
> In userland, you can even implement this by machine learning.
>
> For every connection you made, you get the 4-tuple and INCOMING_CPU,
> then you store it in a cache.

Eww :(

>
> Next time you need to connect to same remote peer, you can lookup in the
> cache to find a good candidate.
>
> It would actually be good if we could do in a single socket verb a
> bind_and_connect(fd, &source, &destination)

Fair enough.  Although for my use case, the time it takes to connect
is completely irrelevant.

--Andy

>
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
