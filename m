From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Sat, 27 Aug 2016 10:58:41 -0700
Message-ID: <192979DC-62CB-4767-BA30-21ECADD8C727@gmail.com>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org> <20160826.212939.1362447220540461922.davem@davemloft.net> <57C186FF.6090702@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
        shankerd@codeaurora.org, vikrams@codeaurora.org,
        cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
        andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
        jcm@redhat.com, agross@codeaurora.org, LinoSanfilippo@gmx.de
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <57C186FF.6090702@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On August 27, 2016 5:26:39 AM PDT, Timur Tabi <timur@codeaurora.org> wrote:
>David Miller wrote:
>> From: Timur Tabi <timur@codeaurora.org>
>> Date: Thu, 25 Aug 2016 16:39:03 -0500
>>
>>> +static const u8 duuid[] = {
>>> +	0x77, 0x79, 0x60, 0xbf,
>>> +	0x2d, 0xab,
>>> +	0x9d, 0x4b,
>>> +	0x94, 0xf0,
>>> +	0xe1, 0x11, 0x98, 0x01, 0xa2, 0xba
>>> +};
>>
>> This seems to be completely unused, please remove it.
>
>Sorry, I missed that during my cleanup.  I'll remove it in v10.
>
>I wonder why my compiler didn't complain about the unused static.

AFAICT this really depends on how modern your compiler is and which warnings it may now enable by default.

Since you are very close from an accepted driver, you may want to squash potential warnings (and more) with doing a sparse build (make C=) which covers a bit more than what a traditional C compiler does.

Almost there!

-- 
Florian
