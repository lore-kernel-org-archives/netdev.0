From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] net/r8169: update the new parser for the new firmware
Date: Fri, 17 Jun 2011 08:39:48 +0200
Message-ID: <20110617063948.GA2146@electric-eye.fr.zoreil.com>
References: <1308109531-31698-1-git-send-email-hayeswang@realtek.com> <20110616225904.GA2064@electric-eye.fr.zoreil.com> <8AC7DE11560749B895F99EBA7D42AA49@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38411 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603Ab1FQGw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 02:52:26 -0400
Content-Disposition: inline
In-Reply-To: <8AC7DE11560749B895F99EBA7D42AA49@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
> Francois Romieu :
[...]
> > The new firmware format should be the same. The old 
> > r8168d-1.fw firmware proved usable when prefixed with :
> > 
> > 0000000: 0000 0000 3031 0000 0000 0000 0000 0000  ....01..........
> > 0000010: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> > 0000020: 0000 0000 3000 0000 7501 0000 a000 0000  ....0...u.......
> > 
> > I realized after testing that netif_err could be abused with 
> > non-string fw_info.version. :o/
> > 
> 
> Excuse me. I don't understand what you want to express. Do you mean the
> situation of the old paser with the new firmware for checking the firmware?

No. The code does a printk with a %s specifier on fw_info.version while there
is no evidence that fw_info.version is 0 terminated.

> For the normal situation, the old paser would not use the new firmware.
> And I put zero in front of the new firmware to prevent the old paser from
> running it. That is all I do.

It is fine.

-- 
Ueimor
