From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 16:37:57 -0800
Message-ID: <1488328677.9415.280.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
         <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com>
         <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
         <CAF=yD-K_0zO3pMeXf-UKGTsD4sNOdyN9KJkUb5MnCO_J5pisrA@mail.gmail.com>
         <CALCETrUgOpcNO6L3eabAr3P8p86PGYT7BfCt9mcNTu6TNfP7Dw@mail.gmail.com>
         <1488318476.9415.270.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALCETrVQj1AEsLEGGkWW1zApGz6_x2rDmE0wz4ft+O5h07f_Ug@mail.gmail.com>
         <1488321643.9415.272.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALCETrXqO=ptrcHs0kLLfqA2nskGck4ntAnsaJdcjmqNuoVfNQ@mail.gmail.com>
         <1488324131.9415.278.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALx6S357ssnbEu7CMrczEjiX25QYBJh3WG=w8KuAoxGQS4aKLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALx6S357ssnbEu7CMrczEjiX25QYBJh3WG=w8KuAoxGQS4aKLA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-02-28 at 16:28 -0800, Tom Herbert wrote:

> The Mellanox team working on TLS offload pointed out to us that if
> data is changed for a retransmit then it becomes trivial for someone
> snooping to break the encryption. Sounds pretty scary and it would be
> a shame if we couldn't use zero-copy in that use case :-( Hopefully we
> can find a solution...

Right, this is why offloading encryption over TCP is also hard ;)
