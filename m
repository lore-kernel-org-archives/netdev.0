From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Sun, 21 Sep 2003 17:53:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030921175325.0ca95fff.davem@redhat.com>
References: <200309022116.41697.bdschuym@pandora.be>
	<200309172317.38348.bdschuym@pandora.be>
	<20030918194802.6726d53c.davem@redhat.com>
	<200309201332.13167.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, hno@marasystems.com, acme@conectiva.com.br,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200309201332.13167.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 20 Sep 2003 13:32:12 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> On Friday 19 September 2003 04:48, David S. Miller wrote:
> > Don't use an alignment attribute, just put the member of
> > the struct at the very beginning and use "unsigned int"
> > at a time op+comparisons.
> >
> > How about that?
> 
> Fine with me.

Patch applied, thanks Bart.
