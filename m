From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Best way to hook incoming eth pkts?
Date: Wed, 20 Aug 2003 13:51:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820175141.GB23984@gtf.org>
References: <20030820154727.GB9119@gtf.org> <1061401697.12293.8.camel@serpentine.internal.keyresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Bryan O'Sullivan" <bos@serpentine.com>
Content-Disposition: inline
In-Reply-To: <1061401697.12293.8.camel@serpentine.internal.keyresearch.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Aug 20, 2003 at 10:48:17AM -0700, Bryan O'Sullivan wrote:
> On Wed, 2003-08-20 at 08:47, Jeff Garzik wrote:
> 
> > ATA-over-ethernet has its own
> > IANA-registered ethernet type, but netconsole and netdump are using
> > IP/UDP instead of a custom ethernet protocol.
> 
> This is useful, because it minimises the work needed to get them going
> over other transports, such as Myrinet.  I'd rather not see the UDP
> encapsulation go away.  Netconsole is already messy enough to configure
> and deal with; Matt Mackall's 2.6 forward port, that makes configuration
> more IP-oriented instead of less, is a step in the right direction.

Configuration has zero to do with the protocol of choice.

I fully agree that current RH netconsole/netdump configuration is
positively awful...

	Jeff
