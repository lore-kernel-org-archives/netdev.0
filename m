From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Thu, 31 Mar 2016 09:53:26 +0200
Message-ID: <56FCD776.2090206@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>	<56DE7E1D.5070508@st.com>	<CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com>	<CAAObsKD9HoEbtV_JMz_R=bcrQseDmhncRAWP9k8djksL-LMQqw@mail.gmail.com>	<56DFE55B.2090806@st.com>	<56DFE64B.8060606@st.com>	<CAAObsKBr9SXg1-wr9O-ypR8JozdGpeAwfDLMeUKi8ozxkKyTXg@mail.gmail.com>	<56DFF253.9050208@st.com>	<56DFFA9E.7060602@st.com>	<CAAObsKBUzBXcamEyup44N1bYUzGr_ZZTsYcD5x3PXb-2E00cGA@mail.gmail.com>	<56E033C8.40506@st.com>	<56E038CE.606@st.com>	<CADhT+wcMpzA_Coj8Z5OQZsc3bF3a7yOmsbazQMPtcdUWkJSuCA@mail.gmail.com>	<56E13AAB.2080900@st.com>	<CADhT+wd=vcph2y_OxkGNO5EwHvN=kBy-BrfZHmNjZHww4LxmTg@mail.gmail.com>	<56E28B5D.6000708@st.com>	<CAAObsKB-tSCu5KMYk2Zi-oX9zMKEOwwT93sMkiZKiYvtexmHaQ@mail.gmail.com>	<56E6E4B0.8060408@st.com
 >	<CAAObsKCdk+6HdzFYxRKZbPiaKcfMCLjbpngurat47YvyvSgH-w@mail.gmail.com>	<56E801EB.6030107@st.com>
 <CADhT+wdXXp322vmgFmWTUiiRZTsCWeJSSdU=BMEEbSyb_bnrUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 =?UTF-8?B?SGVpa28gU3TDvGJuZXI=?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 =?UTF-8?B?RnJhbmsgU2Now6RmZXI=?= <fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
 "open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Fabrice GASNIER <fabrice.gasnier-qxv4g6HH51o@public.gmane.org>,
 =?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?= <afaerber-l3A5Bk7waGM@public.gmane.org>,
 Tomeu Vizoso <tomeu-XCtybt49RKsYaV1qd6yewg@public.gmane.org>,
 Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
To: Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CADhT+wdXXp322vmgFmWTUiiRZTsCWeJSSdU=BMEEbSyb_bnrUw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/30/2016 6:44 PM, Dinh Nguyen wrote:
> On Tue, Mar 15, 2016 at 7:36 AM, Giuseppe CAVALLARO
> <peppe.cavallaro-qxv4g6HH51o@public.gmane.org> wrote:
>> Hello Tomeu
>>
>> On 3/15/2016 8:23 AM, Tomeu Vizoso wrote:
>>>
>>> Thanks.
>>>
>>> Btw, I have rebased on top of 4.5 this morning and I have noticed that
>>> 88f8b1bb41c6 ("stmmac: Fix 'eth0: No PHY found' regression") got in
>>> there, so I guess we have now a bunch of boards with broken network on
>>> that release:(
>>
>>
>>
>> This is the status on my side: I am testing on an HW that has the
>> Enhanced descriptors and all works fine.
>>
>> On this HW, if I force the driver to use the normal descriptor
>> layout, I meet problems but using both net.git and net-next.
>> So I suspect I cannot ply with this HW forcing the normal descriptors.
>> But! That is helping me to check if, on net-next, the stmmac is
>> actually  programming fine the normal desc case.
>> I have just found another fix so I kindly ask you to apply the temp
>> patch  attached and let me know.
>> In details, I have noticed that the OWN bit was not set in the right
>> TDES0.
>>
>> I also ask you to give me a log of the kernel where the stmmac was
>> running fine. I would like to see which configuration it is selected
>> at runtime by the driver on your box.
>>  From your previous logs (where the stmmac failed), it seems that
>> the  problem is on normal desc but, to be honest, this is the first
>> case I see a 3.50a with HW capability register and w/o Enhanced
>> descriptors.
>>
>
> Are you still working on a fix for:
>
> [    1.196110] libphy: PHY stmmac-0:ffffffff not found
> [    1.200972] eth0: Could not attach to PHY
> [    1.204991] stmmac_open: Cannot attach to PHY (error: -19)
>
> I see the error still there as of linux-next 20160330.

this could be because the fixes have been not applied on net-next
I will check and resend all asap

peppe

>
> Dinh
>
