From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Alternative hidden netwirk device interface
Date: Wed, 21 Feb 2007 00:04:59 -0800 (PST)
Message-ID: <20070221.000459.97291017.davem@davemloft.net>
References: <20070129184707.885764375.midnight@suse.cz>
	<20070129102814.6385ad2d@freekitty>
	<20070129140958.0cf6880f@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@suse.cz, netdev@vger.kernel.org, linville@tuxdriver.com,
	shemminger@osdl.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37238
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751167AbXBUIFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 03:05:00 -0500
In-Reply-To: <20070129140958.0cf6880f@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 29 Jan 2007 14:09:58 -0800

> Change to allow register_netdevice() to be called with a blank name.
> If name is blank, it is not put in name hash list, and doesn't
> show up in /sys or /proc
> 
> Compile tested only...

I have no objections to this.

It would be nice to wrap the hlist_unhashed() test around
a well named inline function, such as "netdev_hidden()" or
similar.

With that minor enhancement, and a nice changelog (including
a description of what this would be used for), I'll happily
merge this during the next merge window.

Thanks Stephen.
