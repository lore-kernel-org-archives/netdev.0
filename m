From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Sat, 20 Sep 2003 13:05:26 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030920160526.GB29040@conectiva.com.br>
References: <200309022116.41697.bdschuym@pandora.be> <200309172317.38348.bdschuym@pandora.be> <20030918194802.6726d53c.davem@redhat.com> <200309201332.13167.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, laforge@netfilter.org,
        hno@marasystems.com, netfilter-devel@lists.netfilter.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
Content-Disposition: inline
In-Reply-To: <200309201332.13167.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Sat, Sep 20, 2003 at 01:32:12PM +0200, Bart De Schuymer escreveu:
> On Friday 19 September 2003 04:48, David S. Miller wrote:
> > Don't use an alignment attribute, just put the member of
> > the struct at the very beginning and use "unsigned int"
> > at a time op+comparisons.
> >
> > How about that?
> 
> Fine with me.

Fixes the problem on parisc64, just tested, thanks.

- Arnaldo
