From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Tue, 23 Sep 2014 14:04:33 +0400
Message-ID: <542145B1.4030202@msgid.tls.msk.ru>
References: <52BDE9DC.5040206@msgid.tls.msk.ru> <52BE9CF9.7030305@broadcom.com> <52BEC2F6.7010505@msgid.tls.msk.ru> <52D4FC8B.6090301@msgid.tls.msk.ru> <52F925A9.1030707@msgid.tls.msk.ru> <53526124.6050407@msgid.tls.msk.ru> <53FC1789.6020407@msgid.tls.msk.ru> <53FCA001.6090404@broadcom.com> <53FCB2A3.1050605@msgid.tls.msk.ru> <53FCFE1A.3060508@broadcom.com> <53FDACD1.8090805@msgid.tls.msk.ru> <53FDF8EB.4050905@broadcom.com> <54169D4F.2090607@broadcom.com> <541EEF17.7020806@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:40221 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754405AbaIWKEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 06:04:35 -0400
In-Reply-To: <541EEF17.7020806@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

21.09.2014 19:30, Michael Tokarev wrote:
> Namely, after resume, the card does not work. ARP works, ping and
> DNS sometimes/somewhat work, inital TCP connection establisment
> works, but eg http download does not work, it stalls almost
> immediately.

It does not work at all anymore again.  Not only after resume but also
after could power up, it stalls right at start of wget for example.

> http://www.corpit.ru/mjt/tmp/brcmsmac-4313-trace-20140921.dat.gz -- this
> is a trace collected after resuming from suspend-to-disk

And here -- http://www.corpit.ru/mjt/tmp/brcmsmac-4313-trace-20140923.dat.gz
is another trace, after insmod brcmutils & brcmsmac, starting trace-cmd record
(with network-manager running in the background), and running a wget on
http://ip-add-ress-of-the-access-point/somefile (which immediately stalls,
showing minimal progress once in a while only).

Hopefully this will help to find the problem.  And for the record, I'm
_again_ without the wifi network.  But unlike of the previous situation,
I can at least buy some other, better supported wifi adapter now, because
this laptop does not have a bios lock (is 6235ANHMW any good?)

Thanks,

/mjt
