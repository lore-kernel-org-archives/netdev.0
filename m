From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/3] [IPv4]: FIB configuration using struct fib_config
Date: Wed, 9 Aug 2006 01:11:03 +0200
Message-ID: <20060808231102.GT14627@postel.suug.ch>
References: <20060808193822.104083150@postel.suug.ch> <20060808194600.996388029@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:11142 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965061AbWHHXKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 19:10:42 -0400
To: davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20060808194600.996388029@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Thomas Graf <tgraf@suug.ch> 2006-08-08 00:00
> Introduces struct fib_config replacing the ugly struct kern_rta
> prone to ordering issues. Avoids creating faked netlink messages
> for auto generated routes or requests via ioctl.
> 
> A new interface net/nexthop.h is added to help navigate through
> nexthop configuration arrays.
> 
> Since the netlink source pid of the requesting process is stored
> in fib_config, it is no longer required to pass netlink_skb_parms
> all along just for event notification.

Hold on with this patch, netlink pid handling for netlink events
is completely inconsistent. I want to figure out the right way
to do it first.
