From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] stmmac: Add support for SIMATIC IOT2000 platform
Date: Tue, 25 Apr 2017 12:46:14 +0300
Message-ID: <CAHp75VfqC166E57nZRsx97EQCCGnqYTk+4nRX3H2-rsnCohPfQ@mail.gmail.com>
References: <8c536123-6189-e0b6-1977-dc7a521718dd@siemens.com>
 <CAHp75VcdpOXa+aQ6-iKamTAbX9KGZOWpukygSUS7Ef_E3UNvuw@mail.gmail.com>
 <feb4856b-fb66-3861-2121-d2834fb01899@siemens.com> <CAHp75VcTzBL4D6nobfDAPQOfEEp-RzBp4BANKYDSaaEtGCyj9A@mail.gmail.com>
 <d7216317-e749-1347-972f-28dfe57038c0@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Sascha Weisenberger <sascha.weisenberger@siemens.com>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33315 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1428833AbdDYJqP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 05:46:15 -0400
In-Reply-To: <d7216317-e749-1347-972f-28dfe57038c0@siemens.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 12:00 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> On 2017-04-25 09:30, Andy Shevchenko wrote:
>> On Tue, Apr 25, 2017 at 8:44 AM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>>> On 2017-04-24 23:27, Andy Shevchenko wrote:
>>>> On Mon, Apr 24, 2017 at 10:27 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>>>>> The IOT2000 is industrial controller platform, derived from the Intel
>>>>> Galileo Gen2 board. The variant IOT2020 comes with one LAN port, the
>>>>> IOT2040 has two of them. They can be told apart based on the board asset
>>>>> tag in the DMI table.
>>
>>>>> +       const char *asset_tag;
>>>>
>>>> I guess this is redundant. See below.
>>>>
>>>>> +       {
>>>>> +               .name = "SIMATIC IOT2000",
>>>>> +               .asset_tag = "6ES7647-0AA00-0YA2",
>>>>> +               .func = 6,
>>>>> +               .phy_addr = 1,
>>>>> +       },
>>>>
>>>> The below has same definition disregard on asset_tag.
>>>>
>>>
>>> There is a small difference in the asset tag, just not at the last digit
>>> where one may expect it, look:
>>>
>>> ...-0YA2 -> IOT2020
>>> ...-1YA2 -> IOT2040
>>
>> Yes. And how does it change my statement? You may use one record here
>> instead of two.
>
> How? Please be more verbose in your comments.

       {
               .name = "SIMATIC IOT2000",
               .func = 6,
               .phy_addr = 1,
       },
       {
               .name = "SIMATIC IOT2000",
               .func = 7,
               .phy_addr = 1,
       },

That's all what you need.

>> Got it, though asset_tag here is redundant as well.

> It's not as it is the only differentiating criteria to tell the
> two-ports variant apart from the one-port (and to avoid confusing it
> with any potential future variant).

And why exactly is it needed?
Sorry, but I don't see any reason to blow the code for no benefit.

> We could leave out the name, but I
> kept it for documentation purposes.

Nobody prevents you to add a comment.

-- 
With Best Regards,
Andy Shevchenko
