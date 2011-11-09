From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/usb: Misc. fixes for the LG-VL600 LTE USB modem
Date: Wed, 09 Nov 2011 16:06:25 -0500 (EST)
Message-ID: <20111109.160625.886392843374581983.davem@davemloft.net>
References: <1320808200-28209-1-git-send-email-prox@prolixium.com>
	<1320861104.24903.4.camel@dcbw.foobar.com>
	<20111109185714.GA15884@prolixium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dcbw@redhat.com, oliver@neukum.name, gregkh@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: prox@prolixium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111109185714.GA15884@prolixium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Kamichoff <prox@prolixium.com>
Date: Wed, 9 Nov 2011 13:57:14 -0500

> For (a), it's my understanding that __constant_htons() should be used
> only for initializers and htons() used in other cases, since it handles
> checking for constants.  I suppose you're right and this is a little
> gratuitous, but I wanted to keep things clean.
> 
> As far as (b), sorry!  That's an error on my part.  I must have been
> practicing another coding style at the time.  The braces certainly
> shouldn't be there, let me know if I should resubmit.

Please get rid of the gratuitous htons() etc. changes and keep this
patch purely to the bug fixes and resubmit.

Thank you.
