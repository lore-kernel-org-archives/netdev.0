From: David Chang <dchang@suse.com>
Subject: Re: [PATCH net] r8169: check ALDPS bit and disable it if enabled for
 the 8168g
Date: Thu, 28 Nov 2013 12:29:04 +0800
Message-ID: <20131128042904.GA9297@linux-g7tt.site>
References: <1385538516-32104-1-git-send-email-dchang@suse.com>
 <103D217663F345E1877FB05AC93E3CFF@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "'David S. Miller'" <davem@davemloft.net>,
	'Francois Romieu' <romieu@fr.zoreil.com>, jlee@suse.com,
	'nic_swsd' <nic_swsd@realtek.com>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:39920 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932311Ab3K1EaP (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:0:0>);
	Wed, 27 Nov 2013 23:30:15 -0500
Content-Disposition: inline
In-Reply-To: <103D217663F345E1877FB05AC93E3CFF@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 28, 2013 at 11:37:18AM +0800, hayeswang wrote:
>  David Chang [mailto:dchang@suse.com] 
> > Sent: Wednesday, November 27, 2013 3:49 PM
> > To: netdev@vger.kernel.org
> > Cc: David S. Miller; Francois Romieu; Hayeswang; jlee@suse.com
> > Subject: [PATCH net] r8169: check ALDPS bit and disable it if 
> > enabled for the 8168g
> > 
> [...]
> > +	/* Check ALDPS bit, disable it if enabled */
> > +	rtl_writephy(tp, 0x1f, 0x0a43);
> > +	if (rtl_readphy(tp, 0x10) & 0x0004)
> > +		rtl_w1w0_phy(tp, 0x10, 0x0000, 0x0004);
> > +
> 
> You have to delay at least 10 ms after disable it.
> This makes sure the hw completes the action.
>  

Thanks for your comment. 
I'd add a delay time and send the v2 version.

Regards,
David

> Best Regards,
> Hayes
> 
> 
