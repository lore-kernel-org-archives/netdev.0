From: "Bryan O'Sullivan" <bos@serpentine.com>
Subject: Re: Best way to hook incoming eth pkts?
Date: 20 Aug 2003 10:48:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061401697.12293.8.camel@serpentine.internal.keyresearch.com>
References: <20030820154727.GB9119@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030820154727.GB9119@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-08-20 at 08:47, Jeff Garzik wrote:

> ATA-over-ethernet has its own
> IANA-registered ethernet type, but netconsole and netdump are using
> IP/UDP instead of a custom ethernet protocol.

This is useful, because it minimises the work needed to get them going
over other transports, such as Myrinet.  I'd rather not see the UDP
encapsulation go away.  Netconsole is already messy enough to configure
and deal with; Matt Mackall's 2.6 forward port, that makes configuration
more IP-oriented instead of less, is a step in the right direction.

	<b
