From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2] rhashtable: fix for resize events during table walk
Date: Tue, 14 Jul 2015 23:48:40 +0200
Message-ID: <20150714214840.GB20648@pox.localdomain>
References: <1436190680-21887-1-git-send-email-phil@nwl.cc>
 <alpine.LRH.2.11.1507150031550.15113@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil@nwl.cc>, sparclinux@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, daniel@iogearbox.net,
	geert@linux-m68k.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:34619 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbbGNVsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 17:48:43 -0400
Received: by wibud3 with SMTP id ud3so65966342wib.1
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 14:48:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.11.1507150031550.15113@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/15 at 12:35am, mroos@linux.ee wrote:
> Yes, this fixes the error, thank you.
> 
> The new problem with the test - soft lockup - CPU#0 stuck for 22s! is 
> still there on 360 MHz UltraSparc IIi. I understand it is harmless but 
> is there some easy way to make the test avoid NMI watchdog?
> 
> [   58.374173] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [swapper:1]

They don't show up on my system. I will add a schedule() call to the
long loops.
