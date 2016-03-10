From: Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Thu, 10 Mar 2016 10:47:45 -0600
Message-ID: <CADhT+wd=vcph2y_OxkGNO5EwHvN=kBy-BrfZHmNjZHww4LxmTg@mail.gmail.com>
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
	<CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com>
	<CAAObsKD9HoEbtV_JMz_R=bcrQseDmhncRAWP9k8djksL-LMQqw@mail.gmail.com>
	<56DFE55B.2090806@st.com>
	<56DFE64B.8060606@st.com>
	<CAAObsKBr9SXg1-wr9O-ypR8JozdGpeAwfDLMeUKi8ozxkKyTXg@mail.gmail.com>
	<56DFF253.9050208@st.com>
	<56DFFA9E.7060602@st.com>
	<CAAObsKBUzBXcamEyup44N1bYUzGr_ZZTsYcD5x3PXb-2E00cGA@mail.gmail.com>
	<56E033C8.40506@st.com>
	<56E038CE.606@st.com>
	<CADhT+wcMpzA_Coj8Z5OQZsc3bF3a7yOmsbazQMPtcdUWkJSuCA@mail.gmail.com>
	<56E13AAB.2080900@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tomeu Vizoso <tomeu-XCtybt49RKsYaV1qd6yewg@public.gmane.org>,
	=?UTF-8?Q?Andreas_F=C3=A4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>,
	Fabrice GASNIER <fabrice.gasnier-qxv4g6HH51o@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
	=?UTF-8?Q?Frank_Sch=C3=A4fer?= <fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56E13AAB.2080900-qxv4g6HH51o@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2016 at 3:13 AM, Giuseppe CAVALLARO
<peppe.cavallaro-qxv4g6HH51o@public.gmane.org> wrote:
> On 3/9/2016 5:31 PM, Dinh Nguyen wrote:
>>
>> On Wed, Mar 9, 2016 at 8:53 AM, Giuseppe CAVALLARO
>> <peppe.cavallaro-qxv4g6HH51o@public.gmane.org> wrote:
>>>
>>> Hi Tomeu, Dinh, Andreas
>>>
>>> I need a sum and help from you to go ahead on the
>>> tx timeout.
>>>
>>> The "stmmac: MDIO fixes" seems to be the candidate to
>>> fix the phy connection and I will send the V2 asap (Andreas' comment).
>>>
>>> So, supposing the probe is ok and phy is connected,
>>> I need your input ...
>>>
>>>   Tomeu: after revering the 0e80bdc9a72d (stmmac: first frame
>>>          prep at the end of xmit routine) the network is
>>>          not stable and there is a timeout after a while.
>>>          The box has 3.50 with normal desc settings.
>>>
>>>   Dinh: the network is ok, I wonder if you can share a boot
>>>         log just to understand if the normal or enhanced
>>>         descriptors are used.
>>>
>>
>> Here it is:
>
> ...
>>
>> [    0.850523] stmmac - user ID: 0x10, Synopsys ID: 0x37
>> [    0.855570]  Ring mode enabled
>> [    0.858611]  DMA HW capability register supported
>> [    0.863128]  Enhanced/Alternate descriptors
>> [    0.867482]  Enabled extended descriptors
>> [    0.871482]  RX Checksum Offload Engine supported (type 2)
>> [    0.876948]  TX Checksum insertion supported
>> [    0.881204]  Enable RX Mitigation via HW Watchdog Timer
>> [    0.886863] socfpga-dwmac ff702000.ethernet eth0: No MDIO subnode found
>> [    0.899090] libphy: stmmac: probed
>> [    0.902484] eth0: PHY ID 00221611 at 4 IRQ POLL (stmmac-0:04) active
>
>
> Thx Dinh, so you are using the Enhanced/Alternate descriptors
> I am debugging on my side on a setup with normal descriptors, I let you
> know
>

Doesn't the printout "Enhanced/Alternate descriptors"  mean that I'm using
Enhanced/Alternate descriptors?

Dinh
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
