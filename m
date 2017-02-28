From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 14:25:31 -0800
Message-ID: <CALCETrVQj1AEsLEGGkWW1zApGz6_x2rDmE0wz4ft+O5h07f_Ug@mail.gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
 <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com>
 <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
 <CAF=yD-K_0zO3pMeXf-UKGTsD4sNOdyN9KJkUb5MnCO_J5pisrA@mail.gmail.com>
 <CALCETrUgOpcNO6L3eabAr3P8p86PGYT7BfCt9mcNTu6TNfP7Dw@mail.gmail.com> <1488318476.9415.270.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1488318476.9415.270.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2017 at 1:47 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, 2017-02-28 at 13:09 -0800, Andy Lutomirski wrote:
>
>> Does this mean that a user program that does a zerocopy send can cause
>> a retransmitted segment to contain different data than the original
>> segment?  If so, is that okay?
>
> Same remark applies to sendfile() already

True.

>, or other zero copy modes
> (vmsplice() + splice() )

I hate vmsplice().  I thought I remembered it being essentially
disabled at some point due to security problems.

>
