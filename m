From: Thomas Graf <tgraf@suug.ch>
Subject: Re: WCONF, netlink based WE replacement.
Date: Fri, 13 Jan 2006 14:15:03 +0100
Message-ID: <20060113131503.GA379@postel.suug.ch>
References: <200601121824.02892.mbuesch@freenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030271AbWAMNOn@vger.kernel.org>
To: Michael Buesch <mbuesch@freenet.de>
Content-Disposition: inline
In-Reply-To: <200601121824.02892.mbuesch@freenet.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Michael Buesch <mbuesch@freenet.de> 2006-01-12 18:24
> This is an attempt to rewrite the Wireless Extensions
> userspace API, using netlink sockets.
> There should also be a notification API, to inform
> userspace for changes (config changes, state changes, etc).
> It is not implemented, yet.

I'll only comment on the netlink bits and leave the rest to
others. I'd highly recommend the use of attributes instead
of fixed message structures to allow the interface to be
flexible to extensions while staying binary compatible.

Another idea might be to use the new generic netlink family
to make things a bit easier to use.
