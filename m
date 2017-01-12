From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Thu, 12 Jan 2017 11:11:31 +0100
Message-ID: <57d96ccb-7fd4-0707-4902-a5bdd2a6ef39@st.com>
References: <cover.1484059674.git.jpinto@synopsys.com>
 <c74e6665ca14a4ca03b38cd3442ef0644d9e250d.1484059674.git.jpinto@synopsys.com>
 <5b5a3231-eed4-ef29-b32a-a19077681dad@gmail.com>
 <a2d2e457-47e5-bb73-a059-0cb907a29ae0@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <lars.persson@axis.com>, <niklass@axis.com>,
        <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>,
        Florian Fainelli <f.fainelli@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:15874 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750827AbdALKLm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 05:11:42 -0500
In-Reply-To: <a2d2e457-47e5-bb73-a059-0cb907a29ae0@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joao

On 01/12/2017 10:43 AM, Joao Pinto wrote:
>
> Hi Florian,
>
> Às 9:14 PM de 1/11/2017, Florian Fainelli escreveu:
>> On 01/10/2017 06:52 AM, Joao Pinto wrote:
>>> This patch renames stmicro/stmmac to synopsys/ since it is a standard
>>> ethernet software package regarding synopsys ethernet controllers, supporting
>>> the majority of Synopsys Ethernet IPs. The config IDs remain the same, for
>>> retro-compatibility, only the description was changed.
>>
>> Do re really have to do this? ST Micro were the first to upstream
>> support for a Synopsys IP, and it was later on identified as being
>> "stmicro" instead of "synopsys" (during the big driver move under
>> drivers/net/ethernet) whichever came first in the driver essentially "wins".
>>
>> As mentioned before, although git is able to track renames, git log does
>> not automatically have --follow, so it can be hard for people to track
>> down the (new) history of the driver.
>>
>> Personally, I don't see much value in doing this rename, especially when
>> all the driver internal structures are still going to be named with
>> stmmac (and please don't even think about doing a s/stmmac/snps/ inside
>> the driver ;)).
>>
>> My 2 cents.
>>
>
> First of all, I am suggesting an alternative way of organizing the code, and
> that's it, I have no second intentions about anything :).
>
> Please don't see this as a take-over or erase Stmicro from credits, please... it
> makes no sense. You can leave STMicro license and all the credits fine by me and
> I insist on it. But lets name it for something that makes sense... lets call it
> dwc (designware controllers), I am totally open to suggestions.
>
> I don't understand the hostility of some comments, honestly.
>
> The easiest way is to keep things like they are today, and believe me I have a
> lot of things to do, like adding the support of multi-queues / multi-channels to
> stmmac, so I not suggesting this because it is fun.
>
> I am suggesting this because it is what I am used to seeing in other subsystems.
> USB has dwc2 and dwc3 folders that clearly identifies that they are Designware
> (synopsys) extensions to the USB 2.0 and 3.0. The author of dwc3 was Texas
> Instruments, and they did not name it ti/usb. For example I use an AXS101
> Development board that does not have a stmicro SoC but has a Designware Ethernet
> IP in it, so uses stmicro/stmmac. For me it is confusing.
>
> Lets not name it synopsys, for me it is totally fine, but naming it
> stmicro/stmmac is not the right way because it seems like it is a driver just
> for stmicro products, which is not, is for products that use Designware Ethernet
> IPs.
>
> I am volunteering to do this work, let's discuss this.

For me it makes no sens to rename only folder (stmicro/stmmac by 
synopsys) and keep stmmac* inside a synopsys folder (that is very 
confusing). If you propose that you have to change all.

BUT doing that, we will lose all stmmac driver story and we don't want 
that.



>
> Thanks,
> Joao
>
>
