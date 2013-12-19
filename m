From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] hyperv: Add support for Virtual Receive Side
 Scaling (vRSS)
Date: Thu, 19 Dec 2013 15:30:40 -0800
Message-ID: <CA+mtBx_g6X_hs_Mn-SvRXqV+c_qmDV8YSynVBqTyaoimr9+3Ww@mail.gmail.com>
References: <1387405262-18334-1-git-send-email-haiyangz@microsoft.com>
	<1387475178.1876.29.camel@bwh-desktop.uk.level5networks.com>
	<ff7f7541d0164d408b3a4278569c593a@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
	<52B33EC1.5040901@redhat.com>
	<6ee28c6a94e74c958ee96c3547741fb9@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
	<CA+mtBx-BBBQjVTOrnaow=GNc7VM5D2Zj8xr=fPM4b4f_xT7qkQ@mail.gmail.com>
	<05be4f23ff784e56b710dd02eb88358a@DFM-DB3MBX15-08.exchange.corp.microsoft.com>
	<CA+mtBx_SSPd6s5519dWCyPGmFvO=kE+Fh3ZQ9w9oo=pJraRAFQ@mail.gmail.com>
	<3eb3eb6885704b6098c39fad1fdfc443@DFM-DB3MBX15-08.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:59176 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756761Ab3LSXam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 18:30:42 -0500
Received: by mail-ie0-f180.google.com with SMTP id tp5so2287742ieb.39
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 15:30:41 -0800 (PST)
In-Reply-To: <3eb3eb6885704b6098c39fad1fdfc443@DFM-DB3MBX15-08.exchange.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 3:15 PM, Haiyang Zhang <haiyangz@microsoft.com> wrote:
>> -----Original Message-----
>> From: Tom Herbert [mailto:therbert@google.com]
>> Sent: Thursday, December 19, 2013 4:43 PM
>> To: Haiyang Zhang
>> Cc: Daniel Borkmann; Ben Hutchings; davem@davemloft.net;
>> netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
>> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
>> devel@linuxdriverproject.org
>> Subject: Re: [PATCH net-next] hyperv: Add support for Virtual Receive Side
>> Scaling (vRSS)
>>
>> Patch is below. This version did most pre-computation of the variants I built,
>> but results in largest table (40*256*4 bytes), This gives performance roughly
>> comparable with jhash (roughly same as jhash for IPv4, about 30% more
>> cycles for IPv6). I have the simpler less memory intensive versions also if
>> you're interested, these are 10x worse cycles so I wouldn't want those in
>> critical path.
>> ----
>
> Thank you for the code. We like the fast implementation even it uses a bit more
> memory. Are you going to address the comments and re-submit the code soon?
>
I'll take another look now that there's some new motivation :-)

> Thanks,
> - Haiyang
