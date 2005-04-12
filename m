From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: Why skbuff.h different for 2.4 and 2.6 kernels?
Date: Mon, 11 Apr 2005 22:56:35 -0300
Message-ID: <39e6f6c705041118561348e2d9@mail.gmail.com>
References: <20050412012614.69495.qmail@web52209.mail.yahoo.com>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux lover <linux_lover2004@yahoo.com>
In-Reply-To: <20050412012614.69495.qmail@web52209.mail.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Apr 11, 2005 10:26 PM, linux lover <linux_lover2004@yahoo.com> wrote:
> Hello,
>         Thanks for reply. Can you please tell me about
> my second question?
>       2)But Why header structures for ipcomp, eh,
> esp(IPSEC) not included in skbuff.h?

I thought I have answered this, the reason to have the layer pointers in skb
be void is that skb is core/generic infrastructure, it should not have any kind
of protocol specific structures/information in it.

- Arnaldo
