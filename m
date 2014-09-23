From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Tue, 23 Sep 2014 22:10:22 +0400
Message-ID: <5421B78E.4050908@msgid.tls.msk.ru>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <53FDF8EB.4050905@broadcom.com> <54169D4F.2090607@broadcom.com> <541EEF17.7020806@msgid.tls.msk.ru> <542145B1.4030202@msgid.tls.msk.ru> <54216BF1.3060500@broadcom.com> <20140923134419.GA19016@ubuntu-hedt> <54217AA5.2060803@broadcom.com> <542182BE.2000606@msgid.tls.msk.ru> <542183A6.4070207@msgid.tls.msk.ru> <20140923143124.GC19016@ubuntu-hedt> <54219984.2080601@msgid.tls.msk.ru> <5421AF5C.6000106@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Seth Forshee <seth.forshee@canonical.com>,
	brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:46565 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755293AbaIWSKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 14:10:24 -0400
In-Reply-To: <5421AF5C.6000106@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

23.09.2014 21:35, Arend van Spriel wrote:
> On 09/23/14 18:02, Michael Tokarev wrote:

>> Oh. Indeed.  While I enabled it, I recompiled only drivers/net/wireless,
>> but not net/.  Rebuilt, another trace is here --
>>
>>   http://www.corpit.ru/mjt/tmp/brcmsmac-4313-trace-201409233.dat.gz
>>
>> Thanks,
> 
> Just to confirm. With this trace you also get a stall during wget?

Yes.  Initially it started d/loading but some time later the d/load speed
reduced to 0.  It is possible to wait further, and after some more time
it will receive some more bytes/kilobytes/packets and stall again.  Overall
progress is nearing zero.

Thanks,

/mjt
