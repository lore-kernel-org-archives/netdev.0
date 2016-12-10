From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Synopsys Ethernet QoS
Date: Fri, 9 Dec 2016 17:44:03 -0800
Message-ID: <556353b7-c847-7549-626d-3c324063647e@gmail.com>
References: <2df7a6dd-1128-d1d6-bf61-891f76cf7200@synopsys.com>
 <20161209.103327.1742213347114742435.davem@davemloft.net>
 <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net>
 <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
 <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        lars.persson@axis.com, rabin.vincent@axis.com,
        netdev <netdev@vger.kernel.org>, CARLOS.PALMINHA@synopsys.com,
        Jie.Deng1@synopsys.com
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34704 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751631AbcLJBoG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 20:44:06 -0500
Received: by mail-oi0-f67.google.com with SMTP id m75so4484700oig.1
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 17:44:05 -0800 (PST)
In-Reply-To: <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/09/16 à 16:16, Andy Shevchenko a écrit :
> On Sat, Dec 10, 2016 at 12:52 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 
>> It's kind of sad that customers of that IP (stmmac, amd-xgbe, sxgbe)
> 
>> did
>> actually pioneer the upstreaming effort, but it is good to see people
>> from Synopsys willing to fix that in the future.
> 
> Wait, you would like to tell that we have more than 2 drivers for the
> same (okay, same vendor) IP?!
> It's better to unify them earlier, than have n+ copies.

Unfortunately that is the case, see this email:

https://www.mail-archive.com/netdev@vger.kernel.org/msg142796.html

dwc_eth_qos and stmmac have some overlap. There seems to be work
underway to unify these two to begin with.

> 
> P.S. Though, I don't see how sxgbe got in the list. First glance on
> the code doesn't show similarities.

Well samsung/sxgbe looks potentially similar to amd/xgbe, but that's
just my cursory look at the code, it may very well be something entirely
different. The descriptor formats just look suspiciously similar.
-- 
Florian
