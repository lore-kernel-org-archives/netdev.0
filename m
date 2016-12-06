From: Alex <alex.g@adaptrum.com>
Subject: Re: [PATCH] drivers: net: cpsw-phy-sel: Clear RGMII_IDMODE on "rgmii"
 links
Date: Tue, 6 Dec 2016 10:56:08 -0800
Message-ID: <4e431f17-272e-54f9-e7b8-0365d712634e@adaptrum.com>
References: <1480988033-16535-1-git-send-email-alex.g@adaptrum.com>
 <20161206.113630.1454582039498444818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, gokhan@adaptrum.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161206.113630.1454582039498444818.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/06/2016 08:36 AM, David Miller wrote:
> From: Alexandru Gagniuc <alex.g@adaptrum.com>
> Date: Mon,  5 Dec 2016 17:33:53 -0800
>
>> Support for setting the RGMII_IDMODE bit was added in commit:
>> "drivers: net: cpsw-phy-sel: add support to configure rgmii internal delay"
>> However, that commit did not add the symmetrical clearing of the bit
>> by way of setting it in "mask". Add it here.
>>
>> Note that the documentation marks clearing this bit as "reserved",
>> however, according to TI, support for delaying the clock does exist in
>> the MAC, although it is not officially supported.
>> We tested this on a board with an RGMII to RGMII link that will not
>> work unless this bit is cleared.
>>
>> Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>
>
> Commits must be referenced by both short-form SHA1-ID as well as
> the commit header text.
>
> And since this change is fixing that commit, you should also provide
> a proper "Fixes: " tag on the line right before your signoff.

Thank you very much for the feedback. I will update accordingly.

Alex

> Thanks.
>
