From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Tue, 15 Mar 2016 13:36:59 +0100
Message-ID: <56E801EB.6030107@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de> <56DDA3D5.3090209@st.com> <56DDB749.1020808@suse.de> <CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com> <56DE7E1D.5070508@st.com> <CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com> <CAAObsKD9HoEbtV_JMz_R=bcrQseDmhncRAWP9k8djksL-LMQqw@mail.gmail.com> <56DFE55B.2090806@st.com> <56DFE64B.8060606@st.com> <CAAObsKBr9SXg1-wr9O-ypR8JozdGpeAwfDLMeUKi8ozxkKyTXg@mail.gmail.com> <56DFF253.9050208@st.com> <56DFFA9E.7060602@st.com> <CAAObsKBUzBXcamEyup44N1bYUzGr_ZZTsYcD5x3PXb-2E00cGA@mail.gmail.com> <56E033C8.40506@st.com> <56E038CE.606@st.com> <CADhT+wcMpzA_Coj8Z5OQZsc3bF3a7yOmsbazQMPtcdUWkJSuCA@mail.gmail.com> <56E13AAB.2080900@st.com> <CADhT+wd=vcph2y_OxkGNO5EwHvN=kBy-BrfZHmNjZHww4LxmTg@mail.gmail.co
 m> <56E28B5D.6000708@st.com> <CAAObsKB-tSCu5KMYk2Zi-oX9zMKEOwwT93sMkiZKiYvtexmHaQ@mail.gmail.com> <56E6E4B0.8060408@st.com> <CAAObsKCdk+6HdzFYxRKZbPiaKcfMCLjbpngurat47YvyvSgH-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------000706010800070300010608"
Cc: Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?= <afaerber-l3A5Bk7waGM@public.gmane.org>,
	Fabrice GASNIER <fabrice.gasnier-qxv4g6HH51o@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?UTF-8?B?SGVpa28gU3TDvGJuZXI=?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
	=?UTF-8?B?RnJhbmsgU2Now6RmZXI=?= <fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tomeu Vizoso <tomeu-XCtybt49RKsYaV1qd6yewg@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAAObsKCdk+6HdzFYxRKZbPiaKcfMCLjbpngurat47YvyvSgH-w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--------------000706010800070300010608
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit

Hello Tomeu

On 3/15/2016 8:23 AM, Tomeu Vizoso wrote:
> Thanks.
>
> Btw, I have rebased on top of 4.5 this morning and I have noticed that
> 88f8b1bb41c6 ("stmmac: Fix 'eth0: No PHY found' regression") got in
> there, so I guess we have now a bunch of boards with broken network on
> that release:(


This is the status on my side: I am testing on an HW that has the
Enhanced descriptors and all works fine.

On this HW, if I force the driver to use the normal descriptor
layout, I meet problems but using both net.git and net-next.
So I suspect I cannot ply with this HW forcing the normal descriptors.
But! That is helping me to check if, on net-next, the stmmac is
actually  programming fine the normal desc case.
I have just found another fix so I kindly ask you to apply the temp
patch  attached and let me know.
In details, I have noticed that the OWN bit was not set in the right
TDES0.

I also ask you to give me a log of the kernel where the stmmac was
running fine. I would like to see which configuration it is selected
at runtime by the driver on your box.
 From your previous logs (where the stmmac failed), it seems that
the  problem is on normal desc but, to be honest, this is the first
case I see a 3.50a with HW capability register and w/o Enhanced
descriptors.

Best Regards
Peppe

> Regards,
>
> Tomeu


--------------000706010800070300010608
Content-Type: text/x-patch; name="tmp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="tmp.patch"

diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index e13228f..44c052f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -217,10 +217,10 @@ static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 	if (ls)
 		tdes1 |= TDES1_LAST_SEGMENT;
 
-	if (tx_own)
-		tdes1 |= TDES0_OWN;
-
 	p->des1 = tdes1;
+
+	if (tx_own)
+		p->des0 |= TDES0_OWN;
 }
 
 static void ndesc_set_tx_ic(struct dma_desc *p)

--------------000706010800070300010608--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
