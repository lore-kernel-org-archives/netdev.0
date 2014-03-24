From: Alon Nafta <alon@privatecore.com>
Subject: Re: [PATCH 1/4 V2] Ethernet drivers in 3.14-rc3 kernel: fix 3 buffer
 overflows triggered by hardware devices
Date: Mon, 24 Mar 2014 14:17:32 -0700
Message-ID: <CAKPWWNHA_EYRV__HUMrpLRN9VjrEWiPHEy5+OaFcguXpuwgHAA@mail.gmail.com>
References: <CAKPWWNFZc8v04-GM5Ttoa-CW_zhNmfMCYO2Q-Yh-75qitSUpiA@mail.gmail.com>
	<20140324.131733.723749970605014851.davem@davemloft.net>
	<CAKPWWNF982P7PtuoySy6ncU1mCNFm2RBMEDKr3-QKoCKU-6AMw@mail.gmail.com>
	<20140324.143512.68893694230434555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Laight <David.Laight@aculab.com>,
	netdev <netdev@vger.kernel.org>,
	Grant Grundler <grantgrundler@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:52079 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbaCXVRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 17:17:34 -0400
Received: by mail-la0-f43.google.com with SMTP id e16so4063868lan.2
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 14:17:33 -0700 (PDT)
In-Reply-To: <20140324.143512.68893694230434555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I agree that the limit is reached where there is performance overheads
or code bloat, but since neither are introduced in this case, I'd
argue that if drivers can be made more secure by "paying" a minimal
cost, they should.

On Mon, Mar 24, 2014 at 11:35 AM, David Miller <davem@davemloft.net> wrote:
> From: Alon Nafta <alon@privatecore.com>
> Date: Mon, 24 Mar 2014 10:35:37 -0700
>
>> Moreover, a system can be protected from malicious HW, and in fact
>> doesn't have to trust HW at all (except for the CPU obviously).
>
> So should we check to make sure the program counter of the cpu really
> increments to the next instruction every time?
>
> There is a limit to everything.
>
> The length field of DMA descriptors is absolutely, fully, trusted in
> the vast majority of drivers.
