From: linux lover <linux_lover2004@yahoo.com>
Subject: Re: Why skbuff.h different for 2.4 and 2.6 kernels?
Date: Mon, 11 Apr 2005 19:13:57 -0700 (PDT)
Message-ID: <20050412021357.11194.qmail@web52210.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: 6667
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--- Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
wrote:
> On Apr 11, 2005 10:26 PM, linux lover

Hello,
            Sorry if my questions are stupid but again
have one question when skbuff.h is implemeted as
     void *transport_header;
        void *network_header;
        void *link_header;
          
            Then how say ESP packet can be constructed
in network stack. ESP has structure as 
       New IP header + ESP header + IP header +
TCP/UDP header + ESP trailer + ESP auth. header
           Does it then remains only with playing
skbuff by using skb_push and skb_pull in ESP packet
processing once skbuff.h will change?
Please kindly correct me to understand this.
regards,
linux_lover.

 <linux_lover2004@yahoo.com> wrote:
> > Hello,
> >         Thanks for reply. Can you please tell me
> about
> > my second question?
> >       2)But Why header structures for ipcomp, eh,
> > esp(IPSEC) not included in skbuff.h?
> 
> I thought I have answered this, the reason to have
> the layer pointers in skb
> be void is that skb is core/generic infrastructure,
> it should not have any kind
> of protocol specific structures/information in it.
> 
> - Arnaldo
> 


		
__________________________________ 
Do you Yahoo!? 
Yahoo! Small Business - Try our new resources site!
http://smallbusiness.yahoo.com/resources/
