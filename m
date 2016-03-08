From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Tue, 8 Mar 2016 08:24:13 +0100
Message-ID: <56DE7E1D.5070508@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>	<56DD7172.4000707@suse.de>	<2714888.1DdqvJZ8cb@diego>	<56DD7593.5060003@suse.de>	<56DD8176.2080603@st.com>	<56DD8FBE.9010200@suse.de>	<56DD99A4.5030004@st.com>	<56DDA26C.3050301@suse.de>	<56DDA3D5.3090209@st.com>	<56DDB749.1020808@suse.de>
 <CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 =?UTF-8?B?SGVpa28gUw==?= =?UTF-8?B?dMO8Ym5lcg==?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Fabrice GASNIER <fabrice.gasnier-qxv4g6HH51o@public.gmane.org>,
 LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
To: Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, =?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?=
 <afaerber-l3A5Bk7waGM@public.gmane.org>, Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

Hi Dinh,

On 3/8/2016 12:22 AM, Dinh Nguyen wrote:
[snip]
>
> I'm seeing the same issue on the SoCFPGA platform:
>
> libphy: PHY stmmac-0:ffffffff not found
> eth0: Could not attach to PHY
> stmmac_open: Cannot attach to PHY (error: -19)
>
> If I just revert:
>
>   "stmmac: Fix 'eth0: No PHY found' regression"
>
> then the issue goes away.

do you have this patch "stmmac: first frame prep at the end of xmit 
routine" ? Or you just reverted
   "stmmac: Fix 'eth0: No PHY found' regression"

maybe we can sum:

   "stmmac: Fix 'eth0: No PHY found' regression"
            that is introducing a problem when a box
            has a transceiver

  "stmmac: first frame prep at the end of xmit routine"
            That is breaking the tx path on arm64

I will check both patches on my side and let you know

peppe

>
> Thanks,
> Dinh
>
