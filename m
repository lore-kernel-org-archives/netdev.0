From: linux lover <linux_lover2004@yahoo.com>
Subject: Re: Why skbuff.h different for 2.4 and 2.6 kernels?
Date: Mon, 11 Apr 2005 18:26:13 -0700 (PDT)
Message-ID: <20050412012614.69495.qmail@web52209.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: 6667
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
        Thanks for reply. Can you please tell me about
my second question?
      2)But Why header structures for ipcomp, eh,
esp(IPSEC) not included in skbuff.h?
 
regards,
linux_lover.

--- Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
wrote:
> On Apr 11, 2005 1:37 PM, linux lover
> <linux_lover2004@yahoo.com> wrote:
> > hello,
> > 1) In 2.4 kernel series skbuff.h has following
> unions
> > for each TCP/IP layer.
> 
> 
> >         union {
> >                 unsigned char   *raw;
> >         } mac;
> > 
> >  why mac union in 2.6 not have ethernet header?
> Also
> > spxhdr and ipxhdr structures are removed from nh
> and h
> > unions.
> 
> Work in progress, the ultimate goal is to get rid of
> all of these unions and
> have just:
> 
>         void *transport_header;
>         void *network_header;
>         void *link_header;
> 
> So just set mac.raw directly and cast it to the
> desired type.
> 
> - Arnaldo
> 


		
__________________________________ 
Do you Yahoo!? 
Yahoo! Small Business - Try our new resources site!
http://smallbusiness.yahoo.com/resources/
