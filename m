From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2 1/4] net: hix5hd2_gmac: add generic compatible string
Date: Mon, 19 Dec 2016 10:04:19 -0600
Message-ID: <CAL_Jsq+Su84DonQbh2KZ2o8JQ0Mqarag60Oq=Dby3y8Doyozxg@mail.gmail.com>
References: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
 <1480944481-118803-2-git-send-email-lidongpo@hisilicon.com>
 <20161209223521.5dnj7l44e663sntl@rob-hp-laptop> <584E871D.7060200@hisilicon.com>
 <CAL_Jsq+d5xHsxMKxbWSYy3cDXnC+HQj3=wun1zxf5PZ_BYrD-Q@mail.gmail.com> <585796D6.1080407@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Mark Rutland <mark.rutland@arm.com>,
        Michael Turquette <mturquette@baylibre.com>,
        Stephen Boyd <sboyd@codeaurora.org>,
        Russell King <linux@armlinux.org.uk>,
        Zhangfei Gao <zhangfei.gao@linaro.org>,
        Yisen Zhuang <yisen.zhuang@huawei.com>, salil.mehta@huawei.com,
        Arnd Bergmann <arnd@arndb.de>, Andrew Lunn <andrew@lunn.ch>,
        Jiancheng Xue <xuejiancheng@hisilicon.com>,
        benjamin.chenhao@hisilicon.com, caizhiyong@hisilicon.com,
        netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dongpo Li <lidongpo@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <585796D6.1080407@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 2:14 AM, Dongpo Li <lidongpo@hisilicon.com> wrote:
> Hi Rob and David,
>
> On 2016/12/12 22:21, Rob Herring wrote:
>> On Mon, Dec 12, 2016 at 5:16 AM, Dongpo Li <lidongpo@hisilicon.com> wrote:
>>> Hi Rob,
>>>
>>> On 2016/12/10 6:35, Rob Herring wrote:
>>>> On Mon, Dec 05, 2016 at 09:27:58PM +0800, Dongpo Li wrote:

[...]

>>>>> @@ -20,7 +25,7 @@ Required properties:
>>>>>
>>>>>  Example:
>>>>>      gmac0: ethernet@f9840000 {
>>>>> -            compatible = "hisilicon,hix5hd2-gmac";
>>>>> +            compatible = "hisilicon,hix5hd2-gemac", "hisilicon,hisi-gemac-v1";
>>>>
>>>> You can't just change compatible strings.
>>>>
>>> Okay, maybe I should name all the compatible string with the suffix "-gmac" instead of
>>> "-gemac". This can keep the compatible strings with the same suffix. Is this okay?
>>> Can I just add the generic compatible string without changing the SoCs compatible string?
>>> Like following:
>>>         gmac0: ethernet@f9840000 {
>>>  -              compatible = "hisilicon,hix5hd2-gmac";
>>>  +              compatible = "hisilicon,hix5hd2-gmac", "hisilicon,hisi-gmac-v1";
>>
>> Yes, this is fine.
>
> As the patch series have been applied to net-next branch,
> in which way should I commit this compatible fix?
> Should I send a new patch fixing this compatible string error with "Fixes: xxx"?
> Looking forward to your reply!

Yes to both.

Rob
