From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [SUNGEM] LLTX support
Date: Thu, 16 Sep 2004 13:13:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916131300.6388d432.davem@davemloft.net>
References: <5cac192f04091423453ae3cb@mail.gmail.com>
	<20040915083559.6c36759f.davem@davemloft.net>
	<5cac192f04091514433c9e13c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f04091514433c9e13c8@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004 23:43:16 +0200
Eric Lemoine <eric.lemoine@gmail.com> wrote:

> On Wed, 15 Sep 2004 08:35:59 -0700, David S. Miller <davem@davemloft.net> wrote:
> > On Wed, 15 Sep 2004 08:45:21 +0200
> > Eric Lemoine <eric.lemoine@gmail.com> wrote:
> > 
> > > The attached patch adds LLTX support to SunGEM NAPI. The tx_lock patch
> > > I just sent must be applied first.
> > 
> > Also applied, thanks Eric.
> > 
> > I remember you mentioning yesterday that Harald's sungem NAPI
> > patch had netpoll support, can you cook up a patch that adds
> > it for current sungem?
> 
> Patch attached. Unlike Harald's, this patch doesn't disable_irq before
> calling gem_interrupt because gem_interrupt is safe to reentrance.

Looks fine to me.  Patch applied, thanks Eric.
