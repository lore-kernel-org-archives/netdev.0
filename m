From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] Alternative hidden netwirk device interface
Date: Tue, 30 Jan 2007 10:09:19 +0000
Message-ID: <20070130100919.GD8548@infradead.org>
References: <20070129184707.885764375.midnight@suse.cz> <20070129102814.6385ad2d@freekitty> <20070129140958.0cf6880f@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41220 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965405AbXA3KJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 05:09:21 -0500
Content-Disposition: inline
In-Reply-To: <20070129140958.0cf6880f@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 29, 2007 at 02:09:58PM -0800, Stephen Hemminger wrote:
> Change to allow register_netdevice() to be called with a blank name.
> If name is blank, it is not put in name hash list, and doesn't
> show up in /sys or /proc

That sounds even better indeed!

Of course register_netdevice should grow a detailed explanation of
this behaviour in the kdoc comment.

