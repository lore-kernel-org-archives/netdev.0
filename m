From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Request to postpone WE-21
Date: Thu, 05 Oct 2006 18:37:00 -0400
Message-ID: <4525890C.6060700@garzik.org>
References: <20061005163113.GB6510@bougret.hpl.hp.com> <20061005204949.GF18408@tuxdriver.com> <20061005215751.GI17517@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:62599 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932399AbWJEWhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 18:37:20 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20061005215751.GI17517@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> This looks somewhat confusing.. WE-20 (and older) included '\0' in both
> the data value and length (well, at least in most drivers and user space
> tools, if I remember correctly), i.e., essid[iwr->u.data.length] would
> be pointing one byte after the '\0' termination.. And since '\0' is
> valid character in SSID (it is just an arbitrary array of octets) it can
> also be the last octet of the SSID and WE-21 style case could have
> essid[iwr->u.data.length - 1] == '\0'..


Remember, the salient point is ensuring that WE<=20 continues to work as 
expecting, without any modification.  If that means a compromise in 
supported SSID values, so be it.  Just like older versions of stat(2) 
syscall, you are stuck with the old interface, warts included.

But if we can support both styles... great!  I'm all for it.  Just 
noting priorities.  Warts and limitations are inevitable with older 
interfaces.

	Jeff


