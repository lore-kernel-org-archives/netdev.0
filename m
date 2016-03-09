From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Wed, 9 Mar 2016 10:00:59 +0100
Message-ID: <56DFE64B.8060606@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
 <56DD7172.4000707@suse.de> <2714888.1DdqvJZ8cb@diego>
 <56DD7593.5060003@suse.de> <56DD8176.2080603@st.com>
 <56DD8FBE.9010200@suse.de> <56DD99A4.5030004@st.com>
 <56DDA26C.3050301@suse.de> <56DDA3D5.3090209@st.com>
 <56DDB749.1020808@suse.de>
 <CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com>
 <56DE7E1D.5070508@st.com>
 <CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com>
 <CAAObsKD9HoEbtV_JMz_R=bcrQseDmhncRAWP9k8djksL-LMQqw@mail.gmail.com>
 <56DFE55B.2090806@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 =?ISO-8859-1?Q?Heiko_St=FCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 =?ISO-8859-1?Q?Frank_Sch=E4?= =?ISO-8859-1?Q?fer?=
 <fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
 "open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Fabrice GASNIER <fabrice.gasnier-qxv4g6HH51o@public.gmane.org>,
 =?ISO-8859-1?Q?Andreas_F=E4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>,
 LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
To: Tomeu Vizoso <tomeu-XCtybt49RKsYaV1qd6yewg@public.gmane.org>, Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <56DFE55B.2090806-qxv4g6HH51o@public.gmane.org>
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

On 3/9/2016 9:56 AM, Giuseppe CAVALLARO wrote:
> Hello
>
> On 3/9/2016 9:35 AM, Tomeu Vizoso wrote:
>>
>> in order to get the onboard network on the Radxa Rock2 to work at all
>> on today's linux-next, I had to revert both commits:
>>
>> * "stmmac: Fix 'eth0: No PHY found' regression" for the drivers to
>> probe and the link to come up, and
>
> I've just sent two patches (on top of net.git) to fix this problem
> pls let me know if these help on your side too.
>
>>
>> * "stmmac: first frame prep at the end of the xmit routine" for the
>> network interface to work at all.
>
> I cannot reproduce it right now but I am looking at this again and let
> you know.
> I will check your output file too

hmm, I think that the problem is around the "normal descriptor"
management that is configured on the boxes where the driver is
failing now. Using enhanced descriptors the network is ok.
I will keep you up-to-date.

peppe

>
> Regards
> peppe
>
>
>> But a few seconds into the nfsroot boot I start getting:
>>
>> [    9.136701] systemd[1]: Started Load Kernel Modules.
>> [   18.116321] nfs: server 10.42.0.1 not responding, still trying
>> [   18.516224] ------------[ cut here ]------------
>> [   18.521024] WARNING: CPU: 1 PID: 0 at net/sched/sch_generic.c:303
>> dev_watchdog+0x284/0x288
>> [   18.529456] NETDEV WATCHDOG: eth0 (rk_gmac-dwmac): transmit queue 0
>> timed out
>>
>> I'm attaching the full boot log.
>>
>> Regards,
>>
>> Tomeu
>>
>
>
