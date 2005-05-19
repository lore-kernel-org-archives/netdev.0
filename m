From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 09:53:34 -0700
Message-ID: <20050519095334.018dd674.akpm@osdl.org>
References: <20050519000809.2fca25c5.akpm@osdl.org>
	<Xine.LNX.4.44.0505190918430.15522-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0505190918430.15522-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Morris <jmorris@redhat.com> wrote:
>
> On Thu, 19 May 2005, Andrew Morton wrote:
> 
> > We should remove the feature.  If there is demonstrated need for multiple
> > instances then it should be done by more conventional means - syscall,
> > allocation of a device major then use the minor as a selector or whatever.
> 
> I'd suggest removing the connector code completely.
> 

How come?  It seems sensible to have library code which consoldates the
common netlink setup and teardown stuff and which offers a higher-level
messaging API, although connector may be a bit overdesigned for that.  The
fork connector guys seemed to find it useful?
