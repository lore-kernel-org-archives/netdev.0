From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Wed, 9 Mar 2016 08:24:14 +0100
Message-ID: <56DFCF9E.5040206@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>	<56DD7172.4000707@suse.de>	<2714888.1DdqvJZ8cb@diego>	<56DD7593.5060003@suse.de>	<56DD8176.2080603@st.com>	<56DD8FBE.9010200@suse.de>	<56DD99A4.5030004@st.com>	<56DDA26C.3050301@suse.de>	<56DDA3D5.3090209@st.com>	<56DDB749.1020808@suse.de>	<CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com>	<56DE7E1D.5070508@st.com> <CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?= <afaerber@suse.de>,
	Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	=?UTF-8?B?SGVpa28gU3TDvGJuZXI=?= <heiko@sntech.de>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>,
	<netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Alexandre TORGUE <alexandre.torgue@st.com>,
	Fabrice GASNIER <fabrice.gasnier@st.com>
To: Dinh Nguyen <dinh.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:47517 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752080AbcCIHYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 02:24:50 -0500
In-Reply-To: <CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dinh

On 3/8/2016 4:45 PM, Dinh Nguyen wrote:
> On Tue, Mar 8, 2016 at 1:24 AM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com> wrote:
>> Hi Dinh,
>>
>> On 3/8/2016 12:22 AM, Dinh Nguyen wrote:
>> [snip]
>>>
>>>
>>> I'm seeing the same issue on the SoCFPGA platform:
>>>
>>> libphy: PHY stmmac-0:ffffffff not found
>>> eth0: Could not attach to PHY
>>> stmmac_open: Cannot attach to PHY (error: -19)
>>>
>>> If I just revert:
>>>
>>>    "stmmac: Fix 'eth0: No PHY found' regression"
>>>
>>> then the issue goes away.
>>
>>
>> do you have this patch "stmmac: first frame prep at the end of xmit routine"
>> ? Or you just reverted
>>    "stmmac: Fix 'eth0: No PHY found' regression"
>
> I only reverted "stmmac: Fix 'eth0: No PHY found' regression". I do have the
> patch "stmmac: first frame prep at the end of the xmit routine", but I did not
> need to revert that patch.

thx for this input.

FYI, I am reworking the code to manage the mdio inside the driver so a
patch will come soon.

peppe

>
> Dinh
>
