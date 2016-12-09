From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Synopsys Ethernet QoS
Date: Fri, 9 Dec 2016 14:52:24 -0800
Message-ID: <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
References: <2df7a6dd-1128-d1d6-bf61-891f76cf7200@synopsys.com>
 <20161209.103327.1742213347114742435.davem@davemloft.net>
 <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net>
 <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        lars.persson@axis.com, rabin.vincent@axis.com,
        netdev <netdev@vger.kernel.org>, CARLOS.PALMINHA@synopsys.com
To: Andy Shevchenko <andy.shevchenko@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34147 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752030AbcLIWw1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 17:52:27 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so3547740pgc.1
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 14:52:27 -0800 (PST)
In-Reply-To: <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2016 02:25 PM, Andy Shevchenko wrote:
> On Fri, Dec 9, 2016 at 5:41 PM, David Miller <davem@davemloft.net> wrote:
> 
>> But one thing I am against is changing the driver name for existing
>> users.  If an existing chip is supported by the stmmac driver for
>> existing users, they should still continue to use the "stmmac" driver.
>>
>> Therefore, if consolidation changes the driver module name for
>> existing users, then that is not a good plan at all.
> 
> You have at least one supporter here. Though I jumped in to the
> discussion very late, not sure if everyone have time to answer to
> that.

I don't have many stakes in the stmmac driver (or other Synopsys drivers
for that matter), but renaming seems like a terrible idea that is going
to make backporting of fixes difficult for distribution.

While moving the driver into a separate directory could be done, and git
knows how to track files, renaming the driver entirely would break many
platforms (including but not limited to, Device Tree) that you may not
have visibility over (compatible strings, properties, and platform
device driver name for instance).

It's kind of sad that customers of that IP (stmmac, amd-xgbe, sxgbe) did
actually pioneer the upstreaming effort, but it is good to see people
from Synopsys willing to fix that in the future.
-- 
Florian
