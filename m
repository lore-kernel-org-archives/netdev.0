From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] stmmac: Add support for SIMATIC IOT2000 platform
Date: Tue, 25 Apr 2017 14:40:03 +0300
Message-ID: <CAHp75VePmW2OU5oHSDDuohWFMqL8DZr0_Wf06wYztabUjmkJ-w@mail.gmail.com>
References: <8c536123-6189-e0b6-1977-dc7a521718dd@siemens.com>
 <CAHp75VcdpOXa+aQ6-iKamTAbX9KGZOWpukygSUS7Ef_E3UNvuw@mail.gmail.com>
 <feb4856b-fb66-3861-2121-d2834fb01899@siemens.com> <CAHp75VcTzBL4D6nobfDAPQOfEEp-RzBp4BANKYDSaaEtGCyj9A@mail.gmail.com>
 <d7216317-e749-1347-972f-28dfe57038c0@siemens.com> <CAHp75VfqC166E57nZRsx97EQCCGnqYTk+4nRX3H2-rsnCohPfQ@mail.gmail.com>
 <42fd4a72-526c-cbd9-52db-9d8b495035ee@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Sascha Weisenberger <sascha.weisenberger@siemens.com>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:36045 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1946955AbdDYLkF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 07:40:05 -0400
In-Reply-To: <42fd4a72-526c-cbd9-52db-9d8b495035ee@siemens.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 1:07 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> On 2017-04-25 11:46, Andy Shevchenko wrote:
>> On Tue, Apr 25, 2017 at 12:00 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>>> On 2017-04-25 09:30, Andy Shevchenko wrote:
>>>> On Tue, Apr 25, 2017 at 8:44 AM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>>>>> On 2017-04-24 23:27, Andy Shevchenko wrote:
>>>>>> On Mon, Apr 24, 2017 at 10:27 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:

>>>>>>> +       {
>>>>>>> +               .name = "SIMATIC IOT2000",
>>>>>>> +               .asset_tag = "6ES7647-0AA00-0YA2",
>>>>>>> +               .func = 6,
>>>>>>> +               .phy_addr = 1,
>>>>>>> +       },
>>>>>>
>>>>>> The below has same definition disregard on asset_tag.
>>>>>>
>>>>>
>>>>> There is a small difference in the asset tag, just not at the last digit
>>>>> where one may expect it, look:
>>>>>
>>>>> ...-0YA2 -> IOT2020
>>>>> ...-1YA2 -> IOT2040
>>>>
>>>> Yes. And how does it change my statement? You may use one record here
>>>> instead of two.
>>>
>>> How? Please be more verbose in your comments.
>>
>>        {
>>                .name = "SIMATIC IOT2000",
>>                .func = 6,
>>                .phy_addr = 1,
>>        },
>>        {
>>                .name = "SIMATIC IOT2000",
>>                .func = 7,
>>                .phy_addr = 1,
>>        },
>>
>> That's all what you need.
>
> Nope. Again: the asset tag is the way to tell both apart AND to ensure
> that we do not match on future devices.

One step at a time. We don't care of future devices. When we will have
an issue we will look at it.

-- 
With Best Regards,
Andy Shevchenko
