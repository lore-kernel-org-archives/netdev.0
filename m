From: Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Mon, 7 Mar 2016 17:22:24 -0600
Message-ID: <CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	=?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
	Fabrice GASNIER <fabrice.gasnier-qxv4g6HH51o@public.gmane.org>
To: =?UTF-8?Q?Andreas_F=C3=A4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56DDB749.1020808-l3A5Bk7waGM@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 7, 2016 at 11:15 AM, Andreas F=C3=A4rber <afaerber-l3A5Bk7waGM@public.gmane.org>=
 wrote:
> Am 07.03.2016 um 16:52 schrieb Giuseppe CAVALLARO:
>> On 3/7/2016 4:46 PM, Andreas F=C3=A4rber wrote:
>>> Am 07.03.2016 um 16:09 schrieb Giuseppe CAVALLARO:
>>>> On 3/7/2016 3:27 PM, Andreas F=C3=A4rber wrote:
>>>>> Indeed, reverting Gabriel's commit fixes the observed error messa=
ges
>>> [...]
>>>>> However, I am unable to ping any hosts on the network now.
>>>>
>>>> hmm, this could be another problem. I wonder if you can
>>>> check which recent patch is introducing the problem on ARM64.
>>>> For example if this depends on Oct_2015 update.
>>>
>>> I've had success reverting drivers/net/ethernet/stmicro/ up to and
>>> including "stmmac: first frame prep at the end of xmit routine", i.=
e.
>>> top 7 commits.
>>
>> Andreas, I will check it and let you know asap.
>
> I verified that it's just these two commits that I need to revert:
>
> "stmmac: Fix 'eth0: No PHY found' regression"
> "stmmac: first frame prep at the end of xmit routine"
>
> Those in between don't cause conflicts and seem to work okay.
>

I'm seeing the same issue on the SoCFPGA platform:

libphy: PHY stmmac-0:ffffffff not found
eth0: Could not attach to PHY
stmmac_open: Cannot attach to PHY (error: -19)

If I just revert:

 "stmmac: Fix 'eth0: No PHY found' regression"

then the issue goes away.

Thanks,
Dinh
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
