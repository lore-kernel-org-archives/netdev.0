From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: [PATCH net-next v3 0/4] Fix OdroidC2 Gigabit Tx link issue
Date: Sun, 18 Dec 2016 14:37:46 +0100
Message-ID: <CAFBinCBxM2Kt1Q2Fo8wBx-Oxc8nRAuhPyt06mvXc4c8pUxt_4g@mail.gmail.com>
References: <1480326409-25419-1-git-send-email-jbrunet@baylibre.com>
 <20161129.193853.827524417068912706.davem@davemloft.net> <e14a3b0c-dc34-be14-48b3-518a0ad0c080@gmail.com>
 <20161129.201331.2207317476589573523.davem@davemloft.net> <162595c2-d403-0070-3399-de03c1653065@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, carlo@caione.org, khilman@baylibre.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com, neolynx@gmail.com,
        andrew@lunn.ch, narmstrong@baylibre.com,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>, jbrunet@baylibre.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36381 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751769AbcLRNiI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2016 08:38:08 -0500
In-Reply-To: <162595c2-d403-0070-3399-de03c1653065@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian, Hi Jerome,

On Wed, Nov 30, 2016 at 2:15 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 11/29/2016 05:13 PM, David Miller wrote:
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Tue, 29 Nov 2016 16:43:20 -0800
>>
>>> On 11/29/2016 04:38 PM, David Miller wrote:
>>>> From: Jerome Brunet <jbrunet@baylibre.com>
>>>> Date: Mon, 28 Nov 2016 10:46:45 +0100
>>>>
>>>>> This patchset fixes an issue with the OdroidC2 board (DWMAC + RTL8211F).
>>>>> The platform seems to enter LPI on the Rx path too often while performing
>>>>> relatively high TX transfer. This eventually break the link (both Tx and
>>>>> Rx), and require to bring the interface down and up again to get the Rx
>>>>> path working again.
>>>>>
>>>>> The root cause of this issue is not fully understood yet but disabling EEE
>>>>> advertisement on the PHY prevent this feature to be negotiated.
>>>>> With this change, the link is stable and reliable, with the expected
>>>>> throughput performance.
>>>>>
>>>>> The patchset adds options in the generic phy driver to disable EEE
>>>>> advertisement, through device tree. The way it is done is very similar
>>>>> to the handling of the max-speed property.
>>>>
>>>> Patches 1-3 applied to net-next, thanks.
>>>
>>> Meh, there was a v4 submitted shortly after, and I objected to the whole
>>> idea of using that kind of Device Tree properties to disable EEE, we can
>>> send reverts though..
>>
>> Sorry, I lost this in all the discussion, I can revert.
>
> Yeah, I can understand why, these freaking PHYs tend to generate a lot
> of noise and discussion...
>
>>
>> Just send me a revert of the entire merge commit
>> a152c91889556df17ca6d8ea134fb2cb4ac9f893 with a short
>> description of why and I'll apply it.
>
> OK, I will talk with Jerome first to make sure that we are in agreement
> with the solution to deploy to fix the OdroidC2 problem first.
simply because I'm curious: what was the outcome of your discussion?
can we stay with the current solution or are any changes required?


Regards,
Martin
