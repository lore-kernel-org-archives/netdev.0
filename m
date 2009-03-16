From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out,
 resetting -> dead NIC
Date: Mon, 16 Mar 2009 14:23:21 -0700
Message-ID: <1237238601.8839.85.camel@HP1>
References: <bug-12877-10286@http.bugzilla.kernel.org/>
 <20090315143214.90c71fb7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"berni@birkenwald.de" <berni@birkenwald.de>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2922 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761560AbZCPV2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2009 17:28:51 -0400
In-Reply-To: <20090315143214.90c71fb7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 2009-03-15 at 14:32 -0700, Andrew Morton wrote:
> > [784063.389142] tg3: eth0: transmit timed out, resetting
> > [784063.447106] tg3: DEBUG: MAC_TX_STATUS[ffffffff] MAC_RX_STATUS[ffffffff]
> > [784063.524104] tg3: DEBUG: RDMAC_STATUS[ffffffff] WDMAC_STATUS[ffffffff]

At the time of tx timeout, the registers all return 0xffffffff.  Does
the subsequent reset bring the device back?  If the device is brought
back, there should be a link up message and traffic should resume.  If
not, please provide lspci -vvvxxx on the eth0 device after the failure.

Also, when one ethernet port fails, does the other port (from the same
dual port device) function ok?

Thanks.




