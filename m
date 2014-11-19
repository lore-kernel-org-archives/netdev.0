From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Wed, 19 Nov 2014 22:58:34 +0300
Message-ID: <546CF66A.3000207@msgid.tls.msk.ru>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <54363ED0.605@broadcom.com> <CACna6rw3XgdJz0uKkAuas8RTzozTdFp2mgF5g1uo7LHJVSMt4g@mail.gmail.com> <3543341.FmUQFH9nrl@eisbaer> <546C5D1F.108@msgid.tls.msk.ru> <546CD94D.9060509@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	=?UTF-8?B?UmFmYcWCIE1pxYJl?= =?UTF-8?B?Y2tp?= <zajec5@gmail.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	brcm80211 development <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:34376 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756426AbaKST6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 14:58:37 -0500
In-Reply-To: <546CD94D.9060509@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

19.11.2014 20:54, Arend van Spriel wrote:
[]
> In our last email exchange I got the impression you switch to Intel board and did not want to keep replacing cards for testing.

I especially wrote that I have several days to try things out and
if you'll be quick it will be possible for me to test things.
You never replied before now (which is some more months later).

>   Nice to hear you have an alternative setup for this and I assume are willing to do some testing.
> 
> I submitted two patches upstream and additionally I have attached two other that are still under review. Could you try these patches and sent me the content of the two debugfs files 'macstat' and 'hardware' after a stall has occurred.

You didn't tell which kernel it is based on.  So I tried it on 3.16,
ofcourse the patches didn't apply so I hand-edited the debug
printf in drivers/net/wireless/brcm80211/brcmsmac/debug.c (in
3.16 it didn't use seq_printf yet).  So now I have a `hardware'
file (in brcmsmac/bcma0:0/ subdir in debugfs), but not
macstat.  Here's the contents `hardware' one:

chipnum 0x4313
chiprev 0x1
chippackage 0x8
corerev 0x18
boardid 0x1795
boardvendor 0x103c
boardrev P107
boardflags 0x402201
boardflags2 0x884
ucoderev 0x262032c
radiorev 0x1
phytype 0x8
phyrev 0x1
anarev 0xa
nvramrev 8


Since there's no macstats, I guess it is not very useful,
so before digging for too deep, I ask which kernel do you
want me to try here.

Thanks,

/mjt
