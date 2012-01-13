From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH 4/5] brcmsmac: remove PCI suspend/resume from bcma
 driver
Date: Fri, 13 Jan 2012 10:59:05 +0100
Message-ID: <4F100069.3090602@broadcom.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com>
 <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <alpine.LNX.2.00.1201130001320.5860@air.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	"Larry Finger" <Larry.Finger@lwfinger.net>,
	"Alwin Beukers" <alwin@broadcom.com>,
	"Roland Vossen" <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Network Development" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1931 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752627Ab2AMJ7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jan 2012 04:59:17 -0500
In-Reply-To: <alpine.LNX.2.00.1201130001320.5860@air.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2012 09:01 AM, Linus Torvalds wrote:
> 
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Thu, 12 Jan 2012 23:36:52 -0800
> 
> The brcmsmac driver isn't a PCI driver any more, it's a bcma one.  The
> PCI device has been resumed by the PCI driver (the generic PCI layer,
> really), we should be resuming just our own driver state.
> 
> Also add pr_debug() calls to show that we now actually get the
> suspend/resume events.
> 
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

I made similar change as well last night, but did not get to test it. I
will test this series instead.

Gr. AvS
