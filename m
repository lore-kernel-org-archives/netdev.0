From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 11:48:13 -0700 (PDT)
Message-ID: <20050519.114813.85686672.davem@davemloft.net>
References: <20050519000809.2fca25c5.akpm@osdl.org>
	<Xine.LNX.4.44.0505190918430.15522-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@redhat.com
In-Reply-To: <Xine.LNX.4.44.0505190918430.15522-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@redhat.com>
Date: Thu, 19 May 2005 09:19:33 -0400 (EDT)

> On Thu, 19 May 2005, Andrew Morton wrote:
> 
> > We should remove the feature.  If there is demonstrated need for multiple
> > instances then it should be done by more conventional means - syscall,
> > allocation of a device major then use the minor as a selector or whatever.
> 
> I'd suggest removing the connector code completely.

I totally agree, it's crap at the current time and the author doesn't
fix the problems being shown in it, in fact he defends some of them
even this one.  It needs lots of work still.
