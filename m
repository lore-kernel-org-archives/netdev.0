From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: bnx2x: link detected up at startup even when it should be down
Date: Tue, 25 Sep 2012 15:16:05 +0200
Message-ID: <CAL8zT=h31Prm2dpyKM8wwg_cb1a8_0yP2ziNzhNFC-3J1M0Khg@mail.gmail.com>
References: <CAL8zT=hFPQ-NZw8eKQwnktRrcpsOFk3aa_ac5mSWa+TAwyTGBQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2EB97C@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=i_eV3SjuBgdWrBPaE-CoBBVh5QJD8jg-YMoQHDuA4AOQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2F1B50@SJEXCHMB06.corp.ad.broadcom.com>
 <504C9EFCA2D0054393414C9CB605C37F3079E4@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=gp5uZ-Q36=vw--j35txrnLRhguoiMHi8a1kzX=VC3nJg@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F3086A3@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=hJ84woFg0KFxztuTxf2NJEBzThPRXDhZ9KnMJnBxmoZA@mail.gmail.com>
 <CAL8zT=j9LC5hKtmkzBA-Epa+NhX1YpC9RodJ-C+UunTH_HRVKQ@mail.gmail.com> <504C9EFCA2D0054393414C9CB605C37F30910B@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Barak Witkowski <barak@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35357 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756036Ab2IYNQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 09:16:26 -0400
Received: by ieak13 with SMTP id k13so13780722iea.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 06:16:26 -0700 (PDT)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F30910B@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/9/25 Dmitry Kravkov <dmitry@broadcom.com>:
>> -----Original Message-----
>> From: Jean-Michel Hautbois [mailto:jhautbois@gmail.com]
>> Sent: Tuesday, September 25, 2012 2:54 PM
>> To: Dmitry Kravkov
>> Cc: netdev; Barak Witkowski; Eilon Greenstein; davem@davemloft.net
>> Subject: Re: bnx2x: link detected up at startup even when it should be down
>
>
>> After a reboot (with the added if but no netif_msg) :
>
> I'm looking for link messages during device load.
> These (get_setting/set_settings) appear at the later stages.
> Will you able to load driver with module param debug=0x4 instead? So we can catch all link related messages
> (This can be done via /etc/modprobe.conf)
>

Sorry, you said after a reboot, so I used ethtool, I tried to set
bnx2x.debug=4 in cmdline but does not seem to work...
Looking at it...
