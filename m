From: Dinh Nguyen <dinh.linux@gmail.com>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Tue, 8 Mar 2016 09:45:04 -0600
Message-ID: <CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
	<56DD7172.4000707@suse.de>
	<2714888.1DdqvJZ8cb@diego>
	<56DD7593.5060003@suse.de>
	<56DD8176.2080603@st.com>
	<56DD8FBE.9010200@suse.de>
	<56DD99A4.5030004@st.com>
	<56DDA26C.3050301@suse.de>
	<56DDA3D5.3090209@st.com>
	<56DDB749.1020808@suse.de>
	<CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com>
	<56DE7E1D.5070508@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Andreas_F=C3=A4rber?= <afaerber@suse.de>,
	Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	=?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko@sntech.de>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>,
	netdev@vger.kernel.org,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Alexandre TORGUE <alexandre.torgue@st.com>,
	Fabrice GASNIER <fabrice.gasnier@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33517 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008AbcCHPpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 10:45:06 -0500
In-Reply-To: <56DE7E1D.5070508@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 8, 2016 at 1:24 AM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> Hi Dinh,
>
> On 3/8/2016 12:22 AM, Dinh Nguyen wrote:
> [snip]
>>
>>
>> I'm seeing the same issue on the SoCFPGA platform:
>>
>> libphy: PHY stmmac-0:ffffffff not found
>> eth0: Could not attach to PHY
>> stmmac_open: Cannot attach to PHY (error: -19)
>>
>> If I just revert:
>>
>>   "stmmac: Fix 'eth0: No PHY found' regression"
>>
>> then the issue goes away.
>
>
> do you have this patch "stmmac: first frame prep at the end of xmit routine"
> ? Or you just reverted
>   "stmmac: Fix 'eth0: No PHY found' regression"

I only reverted "stmmac: Fix 'eth0: No PHY found' regression". I do have the
patch "stmmac: first frame prep at the end of the xmit routine", but I did not
need to revert that patch.

Dinh
