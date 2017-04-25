From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] stmmac: Add support for SIMATIC IOT2000 platform
Date: Tue, 25 Apr 2017 10:30:18 +0300
Message-ID: <CAHp75VcTzBL4D6nobfDAPQOfEEp-RzBp4BANKYDSaaEtGCyj9A@mail.gmail.com>
References: <8c536123-6189-e0b6-1977-dc7a521718dd@siemens.com>
 <CAHp75VcdpOXa+aQ6-iKamTAbX9KGZOWpukygSUS7Ef_E3UNvuw@mail.gmail.com> <feb4856b-fb66-3861-2121-d2834fb01899@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Sascha Weisenberger <sascha.weisenberger@siemens.com>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:36156 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1175902AbdDYHaU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 03:30:20 -0400
In-Reply-To: <feb4856b-fb66-3861-2121-d2834fb01899@siemens.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 8:44 AM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> On 2017-04-24 23:27, Andy Shevchenko wrote:
>> On Mon, Apr 24, 2017 at 10:27 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>>> The IOT2000 is industrial controller platform, derived from the Intel
>>> Galileo Gen2 board. The variant IOT2020 comes with one LAN port, the
>>> IOT2040 has two of them. They can be told apart based on the board asset
>>> tag in the DMI table.

>>> +       const char *asset_tag;
>>
>> I guess this is redundant. See below.
>>
>>> +       {
>>> +               .name = "SIMATIC IOT2000",
>>> +               .asset_tag = "6ES7647-0AA00-0YA2",
>>> +               .func = 6,
>>> +               .phy_addr = 1,
>>> +       },
>>
>> The below has same definition disregard on asset_tag.
>>
>
> There is a small difference in the asset tag, just not at the last digit
> where one may expect it, look:
>
> ...-0YA2 -> IOT2020
> ...-1YA2 -> IOT2040

Yes. And how does it change my statement? You may use one record here
instead of two.

>
>>> +       {
>>> +               .name = "SIMATIC IOT2000",
>>> +               .asset_tag = "6ES7647-0AA00-1YA2",
>>> +               .func = 6,
>>> +               .phy_addr = 1,
>>> +       },

>>> +       {
>>> +               .name = "SIMATIC IOT2000",
>>> +               .asset_tag = "6ES7647-0AA00-1YA2",
>>> +               .func = 7,
>>> +               .phy_addr = 1,
>>> +       },
>>
>> How this supposed to work if phy_addr is the same?
> That address space is MAC-local, and we have two different MACs here.

Got it, though asset_tag here is redundant as well.

-- 
With Best Regards,
Andy Shevchenko
