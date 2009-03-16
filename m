From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out, resetting
 -> dead NIC
Date: Mon, 16 Mar 2009 23:46:33 +0100
Message-ID: <49BED6C9.7010900@birkenwald.de>
References: <bug-12877-10286@http.bugzilla.kernel.org/> <20090315143214.90c71fb7.akpm@linux-foundation.org> <1237238601.8839.85.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Matthew Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.svr02.mucip.net ([83.170.6.73]:48427 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754042AbZCPWwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 18:52:09 -0400
In-Reply-To: <1237238601.8839.85.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.03.2009 22:23, Michael Chan wrote:
> On Sun, 2009-03-15 at 14:32 -0700, Andrew Morton wrote:
>>> [784063.389142] tg3: eth0: transmit timed out, resetting
>>> [784063.447106] tg3: DEBUG: MAC_TX_STATUS[ffffffff] MAC_RX_STATUS[ffffffff]
>>> [784063.524104] tg3: DEBUG: RDMAC_STATUS[ffffffff] WDMAC_STATUS[ffffffff]
>
> At the time of tx timeout, the registers all return 0xffffffff.  Does
> the subsequent reset bring the device back?  If the device is brought
> back, there should be a link up message and traffic should resume.  If
> not, please provide lspci -vvvxxx on the eth0 device after the failure.

The port does not pass traffic until I rmmod/modprobe the driver or 
reset the whole system, it doesn't recover by itself. "[784081.605984] 
tg3: eth0: Link is down." is the last message I see.

I'll send you the lspci output as soon as it happens again.

> Also, when one ethernet port fails, does the other port (from the same
> dual port device) function ok?

I'm not exactly sure about that, as nowadays there is nothing connected 
to it anymore. However, when the problem first occured there was, and 
I'm pretty sure the second port was okay.

Bernhard
