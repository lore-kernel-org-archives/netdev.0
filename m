From: Roland Dreier <roland@purestorage.com>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 8 Jul 2011 16:11:00 -0700
Message-ID: <CAL1RGDUzN_B0of0Ly6PxxaHM+A+E_1ZA0NTcC6jMmcrcoy0DxQ@mail.gmail.com>
References: <CAL1RGDWbCi_nE8tRp9zyX3Z1yBHKP9ygxNV6TNKp4Up+0g2EPA@mail.gmail.com>
 <20110708.122742.1006323245708104141.davem@davemloft.net> <CAL1RGDWTfchzBSv9rbgfg5DWvqB-Gi-RBpzDPGRUg96fNcf4Bw@mail.gmail.com>
 <20110708.153258.1997707802176810939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: johnwheffner@gmail.com, mj@ucw.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog114.obsmtp.com ([74.125.245.96]:48884 "HELO
	na3sys010aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750805Ab1GHXLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 19:11:21 -0400
Received: by mail-qw0-f47.google.com with SMTP id 5so1364977qwh.20
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2011 16:11:20 -0700 (PDT)
In-Reply-To: <20110708.153258.1997707802176810939.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2011 at 3:32 PM, David Miller <davem@davemloft.net> wrote:
> So what is the cheapest non-linear function we could use?

I'm not comfortable giving cryptographic advice, but even + (addition
with carry) is nonlinear when combined with ^.  However that seems
like the low-order bits might be too predictable.

Maybe * of hash key with a random odd value is good enough?

 - R.
