From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [Regression][v3.10][v3.11] net: Kill link between CSUM and SG features.
Date: Tue, 16 Jul 2013 11:29:32 -0700
Message-ID: <CALnjE+oCeo=T+F3BvTBtcV7oDMPLJAEz1p1sjRGxmE8Wq8gWAg@mail.gmail.com>
References: <51E58C45.1080708@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, ben.howard@canonical.com, edumazet@google.com,
	xiyou.wangcong@gmail.com, alexander.h.duyck@intel.com,
	jiri@resnulli.us, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, kys@microsoft.com,
	haiyangz@microsoft.com
To: Joseph Salisbury <joseph.salisbury@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51E58C45.1080708@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 16, 2013 at 11:09 AM, Joseph Salisbury
<joseph.salisbury@canonical.com> wrote:
> Hi Pravin,
>
> A bug was opened against the Ubuntu kernel[0].  After a kernel bisect,
> it was found that reverting the following commit resolved this bug:
>
> commit ec5f061564238892005257c83565a0b58ec79295
> Author: Pravin B Shelar <pshelar@nicira.com>
> Date:   Thu Mar 7 09:28:01 2013 +0000
>
>     net: Kill link between CSUM and SG features.
>
>
> The regression was introduced as of v3.10-rc1.
>
> I see that you are the author of this patch, so I wanted to run this by
> you.  I was thinking of requesting a revert for v3.11, but I wanted to
> get your feedback first.
>
>
This issue was reported before and turning off sg solves problem for
HyperV driver. Drivers (intel and bnx2x) that I tested works fine with
this patch. Have you seen the issue on any other NIC?


> Thanks,
>
> Joe
>
> [0] http://pad.lv/1200243
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
